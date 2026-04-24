class DealMailerPreview < ActionMailer::Preview
  def deal_submitted
    DealMailer.deal_submitted(deal: Deal.last)
  end

  def deal_terms_send
    DealMailer.deal_terms_send(deal: Deal.last)
  end

  def deal_terms_rejected
    DealMailer.deal_terms_rejected(user: User.first)
  end

  def deal_terms_accepted
    DealMailer.deal_terms_accepted(deal: Deal.last)
  end

  def deal_invite_lender
    DealMailer.invite_lender(deal: Deal.last, lender: Lender.last)
  end

  def lender_committed_capital
    DealMailer.lender_committed_capital(deal: Deal.last, lender: Lender.last, amount: 1000)
  end

  def lender_signature_reminder
    DealMailer.lender_signature_reminder(deal: Deal.last, lender: Lender.last, amount: 1000)
  end

  def funding_completed
    DealMailer.funding_completed(deal: Deal.last)
  end
end
