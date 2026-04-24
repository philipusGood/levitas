class AiDocumentAnalyzer
  class ProcessingError < StandardError; end

  DOCUMENT_ENDPOINT = "https://underwriter.levitas.app"

  def initialize(deal:)
    @deal = deal
  end

  def call
    perform_request
  end

  private

  def perform_request
    payload = {
      documents: documents,
      template_file: Faraday::Multipart::FilePart.new(template_file.path, "application/json")
    }

    response = connection.post("/process", payload)

    raise ProcessingError if response.status != 200

    JSON.parse(response.body).dig("job_id")
  end

  def documents
    file_parts = []

    @deal.documents.each do |document|
      tmpfile = Tempfile.new(document.filename.to_s)
      tmpfile.binmode
      tmpfile.write(document.download)
      tmpfile.rewind

      file_parts << Faraday::Multipart::FilePart.new(
        tmpfile.path,
        document.content_type,
        document.filename.to_s
      )
    end

    file_parts
  end

  def template_file
    local_file_path = Rails.root.join('lib', 'template_file.json')
    file_content = File.read(local_file_path)
    tmp_file = Tempfile.new(File.basename(local_file_path))
    tmp_file.write(file_content)
    tmp_file.rewind
    tmp_file
  end

  def connection
    @connection ||= DocumentExtractor.new.call(multipart: true)
  end
end
