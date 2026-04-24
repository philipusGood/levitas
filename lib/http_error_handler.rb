module HttpErrorHandler
  def self.log_error(response)
    error_message = "API request failed. "

    case response.code
    when 400...500
      error_message += "Client error: #{response.body}"
    when 500...600
      error_message += "Server error: #{response.body}"
    else
      error_message += "Unknown error: #{response.return_message}"
    end

    Rails.logger.error(error_message)
  end
end
