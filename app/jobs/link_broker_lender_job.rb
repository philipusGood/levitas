class LinkBrokerLenderJob < ApplicationJob
  queue_as :default

  def perform(args)
    args = args.with_indifferent_access
    broker_lender = BrokerLender.find_or_initialize_by(
      broker_id: args['broker_id'],
      lender_id: args['lender_id'],
    )

    broker_lender.save
  end
end
