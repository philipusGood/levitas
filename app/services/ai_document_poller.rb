class AiDocumentPoller
  def initialize(ai_documents_pool)
    @ai_documents_pool = ai_documents_pool
    @deal = ai_documents_pool.deal
  end

  def call
    connection.get("/status/#{@ai_documents_pool.job_id}")
  end

  private

  def connection
    @connection ||= DocumentExtractor.new.call
  end
end
