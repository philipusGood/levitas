class RequestSignaturesJob < ApplicationJob
  queue_as :default

  def perform(args)
    deal = Deal.find(args[:deal_id])

    # NOTE: We won't use Docusing
    # RequestSignatures.new(deal: deal).call
  end
end
