class AiDocumentPool < ApplicationRecord
  PROCESSING = "processing"
  COMPLETED = "completed"
  PREFILLED = "prefilled"

  self.table_name = "ai_documents_pools"

  belongs_to :deal

  validates :deal_id, presence: true
  validates :job_id, uniqueness: true
  validates :status, presence: true

  def complete?(refresh: true)
    return true if status == "completed"
    refresh_status! if refresh
  end

  def prefill!
    raise "Not completed" unless complete?

    response_data = DocumentExtractor.new.call(multipart: true).get("/download/#{job_id}")

    if response_data.status == 200
      body = JSON.parse(response_data.body)
      self.update(response: response_data.body)
      if DealPrefiller.new(deal: deal, params: body).call
        DealMailer.prefilled_deal(deal: deal).deliver_later
        self.update(status: "prefilled")
      else
        Rails.logger.info("DealPrefiller failed: #{body}")
      end
    end
  end

  def inconsistencies
    parsed_response["inconsistencies"].values
  end

  def has_inconsistencies?
    inconsistencies.count > 0
  end

  def fetch(key = "")
    keys = key.split(".")
    keys.reduce(parsed_response) do |current_level, key|
      current_level.is_a?(Hash) ? current_level[key] : nil
    end
  end

  private

  def refresh_status!
    response = DocumentExtractor.new.call.get("/status/#{job_id}")

    if response.status == 200
    body = JSON.parse(response.body)
      case body.dig("status")
      when "completado"
        update(status: "completed")
      end
    end
  end

  def parsed_response
    JSON.parse(response).with_indifferent_access
  rescue JSON::ParserError
    {}
  end
end
