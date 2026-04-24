class AiDocumentAnalyzerJob < ApplicationJob
  queue_as :default

  def perform(args)
    deal = Deal.find(args['deal_id'])
    ai_document_pool = AiDocumentPool.find_or_create_by!(deal_id: deal.id)
    job_id = AiDocumentAnalyzer.new(deal: deal).call
    raise "Failing to process documents" if job_id.blank?
    ai_document_pool.update(job_id: job_id, status: AiDocumentPool::PROCESSING)
  end
end
