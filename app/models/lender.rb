class Lender < User
  default_scope { where(role: :lender) }

  after_initialize :set_default_role

  has_many :deal_lenders, class_name: 'DealLender', foreign_key: 'lender_id', dependent: :destroy
  has_many :broker_lenders, dependent: :destroy
  has_many :brokers, through: :broker_lenders

  after_create :link_broker!

  def commited_capital(deal)
    deal_lenders.where(deal_id: deal.id).first.commited_capital
  end

  def commited_deals_from_broker(broker)
    deal_lenders.joins(deal: [:user]).where(deal: { user: broker })
  end

  def deal_available?(deal)
    deal.terms.is_public? || BrokerLender.find_by(broker: deal.user, lender: self)&.accepted?
  end

  def pending_broker_invitations
    broker_lenders.where(status: "pending")
  end

  private

  def password_required?
    return false if skip_password_validation
    super
  end

  def set_default_role
    self.role ||= :lender
  end

  def link_broker!
    if Current.user&.broker?
      BrokerLender.create!(broker_id: Current.user.id, lender_id: self.id)
    end
  end
end
