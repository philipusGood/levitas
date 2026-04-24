class DealCycleRender
  attr_accessor :user, :deal

  def initialize(user:, deal:)
    @user = user
    @deal = deal
  end

  def call
    if user.admin?
      admin_terms_partial
    elsif user.broker? || user.lender?
      broker_terms_partial
    end
  end

  private

  def broker_terms_partial
    case @deal.state
    when "submitted"
      "broker_submitted"
    when "reviewed"
      "broker_reviewed"
    when "rejected"
      "broker_submitted"
    when "accepted"
      "broker_accepted"
    when "funding"
      "broker_funding"
    when "signatures"
      "broker_signatures"
    when "payments"
      "broker_payments"
    when "unfunded"
      "broker_submitted"
    when "closed"
      "broker_closed"
    end
  end

  def admin_terms_partial
    case @deal.state
    when "submitted"
      "admin_submitted"
    when "reviewed"
      "admin_reviewed"
    when "rejected"
      "admin_rejected"
    when "accepted"
      "admin_accepted"
    when "funding"
      "admin_funding"
    when "signatures"
      "admin_signatures"
    when "payments"
      "admin_payments"
    when "unfunded"
      "admin_submitted"
    when "closed"
      "admin_closed"
    end
  end
end
