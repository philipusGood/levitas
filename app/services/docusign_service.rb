class DocusignService
  include HttpErrorHandler

  def initialize
    @dc = Rails.application.credentials.docusign
  end

  def create_and_send_envelope(deal:, lender:, commited_capital:)
    deal_lender = DealLender.find_by(deal_id: deal.id, lender_id: lender.id)

    envelope_definition = {
      status: 'sent',
      templateId: template_id(lender),
      templateRoles: [{
        roleName: 'lender',
        name: lender.full_name,
        email: lender.email,
        clientUserId: lender.id.to_s, # user_id It has to be string
        tabs: {
          textTabs: [
            { tabLabel: 'commitmentDate', value: Date.today.strftime("%m-%d-%Y") },
            { tabLabel: 'lenderId', value: Digest::MD5.hexdigest(lender.email) },
            { tabLabel: 'borrowerName', value: deal&.applicant&.full_name || "" },
            { tabLabel: 'borrowerPhone', value: deal&.applicant&.phone_number || "" },
            { tabLabel: 'borrowerAddress', value: deal&.applicant&.address&.full_address || "" },
            { tabLabel: 'secondBorrowerName', value: deal&.secondary_applicant&.full_name || "" },
            { tabLabel: 'secondBorrowerPhone', value: deal&.secondary_applicant&.phone_number || "" },
            { tabLabel: 'secondBorrowerAddress', value: deal&.secondary_applicant&.address&.full_address || "" },
            { tabLabel: 'propertyAddress', value: deal.name || "" },
            { tabLabel: 'guarantorName', value: deal&.guarantor&.name || "" },
            { tabLabel: 'guarantorPhone', value: deal&.guarantor&.phone_number || "" },
            { tabLabel: 'guarantorAddress', value: deal&.guarantor&.address&.full_address || "" },
            { tabLabel: 'mortgageEncumbrances', value: "" },
            { tabLabel: 'mortgagePriority', value: "" },
            { tabLabel: 'interestCalculated', value: deal.interest_calculated.to_s },
            { tabLabel: 'interestRate', value: deal.terms.interest_rate },
            { tabLabel: 'mortgageTerm', value: deal.terms.terms },
            { tabLabel: 'mortgageAmortization', value: deal.terms.amortization_period },
            { tabLabel: 'paymentFrequency', value: "Monthly" },
            { tabLabel: 'prepaymentTerms', value: deal.terms.prepayment_term },
            { tabLabel: 'closingDate', value: deal.property.approximate_closing_date.to_date.strftime("%m-%d-%Y") },
            { tabLabel: 'interestAdjustmentDate', value: (deal.property.approximate_closing_date.to_date + 12.months).strftime("%m-%d-%Y") },
            { tabLabel: 'maturityDate', value: deal.maturity_date.strftime("%m-%d-%Y") },
            { tabLabel: 'monthlyPayment', value: deal.monthly_cost.round(2).to_s },
            { tabLabel: 'brokerFee', value: deal.broker_fees.total },
            { tabLabel: 'lenderFee', value: deal.terms.lenders_fee },
            { tabLabel: 'legalFee', value: "2000" },
            { tabLabel: 'otherInformation', value: "" },
            { tabLabel: 'commitedCapital', value: deal_lender.commited_capital.to_s },
            { tabLabel: 'commitmentExpiryDate', value: (Date.today + 30.days).strftime("%m-%d-%Y") },
            { tabLabel: 'lenderName', value: lender.name },
            { tabLabel: 'lenderEmail', value: lender.email },
          ],
        },
        idCheckConfigurationName: '77ae27d4-9ea5-48e7-a39c-7b51a975a3b7' # Will replace this with Actual Conf ID once I have identity selected.
      }],
    }

    api_call('envelopes', :post, envelope_definition)
  end

  # We will probably later have to modify this function to send the user back to the deal view, so the return url should be the deal view
  # where the signature was initiated in.
  def get_recipient_view_url(envelope_id:, lender:, deal:)
    recipient_view_request = {
      authenticationMethod: 'none',
      email: lender.email,
      userName: lender.full_name,
      clientUserId: lender.id, # You can use any unique identifier for the signer, probably should use the lenders ID number from Levitas
      returnUrl: "#{host}/deals/#{deal.id}/signing_complete"
    }
    response = api_call("envelopes/#{envelope_id}/views/recipient", :post, recipient_view_request)
    response["url"]
  end

  def get_templates
    api_call('clickapi', :get)
  end


  def construct_consent_uri
    "#{@dc.host}/oauth/auth?response_type=code&scope=#{@dc.scopes}&client_id=#{@dc.integration_key}&redirect_uri=#{@dc.redirect_uri}"
  end

  def construct_jwt
    header = {
      alg: "RS256",
      typ: "JWT"
    }

    body = {
      iss: @dc.integration_key,
      sub: @dc.impersonated_user_id,
      aud: URI.parse(@dc.host).host,
      iat: Time.now.to_i,
      exp: Time.now.to_i + 3600,
      scope: "signature"
    }

    private_key = OpenSSL::PKey::RSA.new(@dc.private_key)
    payload = JWT.encode(body, private_key, 'RS256', header)
    return payload
  end

  def request_access_token(jwt_token)
    url = "#{@dc.host}/oauth/token"
    response = Typhoeus.post(
      url,
      body: {
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt_token
      }
    )

    if response.success?
      begin
        response_body = JSON.parse(response.body)
        @access_token = response_body['access_token']
        @expires_at = Time.now + response_body['expires_in'].to_i
        response_body
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parsing error: #{e.message}"
        nil
      end
    else
      HttpErrorHandler.log_error(response)
      nil
    end
  end

  def access_token_expired?
    @expires_at.nil? || Time.now >= @expires_at
  end


  def refresh_access_token
    if access_token_expired?
      jwt_token = construct_jwt
      response = request_access_token(jwt_token)
      if response
        @access_token = response['access_token']
        @expires_at = Time.now + response['expires_in'].to_i
        Rails.logger.debug "Token refreshed with expiration at #{@expires_at}"
      end
    end
  end

  def api_call(api_endpoint, method, body = nil, retries = 0)
    refresh_access_token if access_token_expired?

    headers = {
      "Authorization" => "Bearer #{@access_token}",
      "Content-Type" => "application/json"
    }
    url = "#{@dc.api_base_url}/accounts/#{@dc.account_id}/#{api_endpoint}"

    response = case method
               when :get
                 Typhoeus.get(url, headers: headers)
               when :post
                 Typhoeus.post(url, headers: headers, body: body.to_json)
               else
                 raise ArgumentError, "Unsupported HTTP method: #{method}"
               end

    handle_response(response, api_endpoint, method, body, retries)
  end

  private

  def handle_response(response, api_endpoint, method, body, retries)
    case response.code
    when 200...299
      parse_response_body(response)
    when 401
      handle_unauthorized(response, api_endpoint, method, body)
    when 429
      handle_rate_limited(response, api_endpoint, method, body, retries)
    else
      log_and_return_error(response)
    end
  end

  def parse_response_body(response)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parsing error: #{e.message}"
    nil
  end

  def handle_unauthorized(response, api_endpoint, method, body)
    HttpErrorHandler.log_info(response)
    refresh_access_token
    api_call(api_endpoint, method, body)
  end

  def handle_rate_limited(response, api_endpoint, method, body, retries)
    if retries >= 10
      HttpErrorHandler.log_error(response)
      Rails.logger.error "Too many retries, breaking loop"
      nil
    else
      HttpErrorHandler.log_debug(response)
      sleep(2**retries)
      api_call(api_endpoint, method, body, retries + 1)
    end
  end

  def log_and_return_error(response)
    HttpErrorHandler.log_error(response)
    nil
  end

  def host
    if Rails.env.production?
      "https://app.levitas.ai"
    elsif Rails.env.staging?
      "https://staging.levitas.ai"
    else
      "http://localhost:3000"
    end
  end

  def template_id(lender)
    already_signed = lender.deal_lenders.where.not(signed_at: nil).exists?

    # TODO: Move to Rails Credentials.
    if Rails.env.production?
      if already_signed
        'd4359d35-4c37-445a-8249-8fc36d53ddc2'
      else
        'b903b590-905f-4ee8-aa39-1265141a3248'
      end
    else
      if already_signed
        'f236f945-706c-4d15-8010-d30975634637'
      else
        '2e51ba84-eb2d-4597-a8a0-c55faf4ffa51'
      end
    end
  end
end
