class DealFlowRender
  attr_accessor :user, :deal

  def initialize(user:, deal:)
    @user = user
    @deal = deal

    @partials_mapping = {
      admin: {
        submitted: 'admin_submitted',
        reviewed: 'admin_submitted',
        rejected: 'admin_submitted',
        accepted: 'admin_accepted',
        funding: 'admin_funding',
        signatures: 'admin_signatures',
        notary: 'admin_notary',
        distribution: 'admin_distribution',
        payments: 'admin_payments',
        unfunded: 'admin_unfunded',
        finalized: 'admin_finalized',
        closed: 'admin_closed'
      },
      broker: {
        submitted: 'broker_submitted',
        reviewed: 'broker_submitted',
        rejected: 'broker_submitted',
        accepted: 'broker_accepted',
        funding: 'broker_funding',
        signatures: 'broker_signatures',
        notary: 'broker_notary',
        distribution: 'broker_distribution',
        payments: 'broker_payments',
        unfunded: 'broker_unfunded',
        finalized: 'broker_finalized',
        closed: 'broker_closed'
      },
      lender: {
        submitted: 'broker_submitted',
        reviewed: 'broker_submitted',
        rejected: 'broker_submitted',
        accepted: 'broker_accepted',
        funding: 'lender_funding',
        signatures: 'broker_signatures',
        notary: 'broker_notary',
        distribution: 'broker_distribution',
        payments: 'broker_payments',
        finalized: 'broker_finalized',
        closed: 'broker_closed'
      }
    }
  end

  def call
    @partials_mapping[user.role.to_sym][@deal.state.to_sym]
  end
end
