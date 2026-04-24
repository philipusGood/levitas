class AiDocumentPollerJob < ApplicationJob
  queue_as :default

  def perform
    process_pending_ai_documents_pools
    prefill_completed_ai_documents_pools
  end

  private

  def process_pending_ai_documents_pools
    AiDocumentPool.where(status: AiDocumentPool::PROCESSING).each do |ai_documents_pool|
      ai_documents_pool.complete?
    end
  end

  def prefill_completed_ai_documents_pools
    AiDocumentPool.where(status: AiDocumentPool::COMPLETED).each do |ai_documents_pool|
      ai_documents_pool.prefill!
    end
  end
end
