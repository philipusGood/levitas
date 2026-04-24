
class DocumentExtractor
  DOCUMENT_ENDPOINT = "https://underwriter.levitas.app"

  def call(multipart: false)
    @connection ||= Faraday.new(url: DOCUMENT_ENDPOINT) do |faraday|
      if multipart
        faraday.request :multipart, flat_encode: true
      end
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end
end
