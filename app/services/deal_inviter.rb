class DealInviter
  attr_reader :deal, :emails, :lenders

  def initialize(deal:, emails:)
    @deal = deal
    @emails = emails
    @lenders = []
  end

  def call
    register_lenders
    send_invitations
  end

  private

  def register_lenders
    emails.each do |email|
      lender = Lender.find_or_initialize_by(email: email)

      invited_lender = if lender.new_record?
        lender.skip_password_validation = true
        lender.skip_confirmation!
        lender.save
        lender
      else
        lender
      end

      if invited_lender
        deal_lender = DealLender.find_or_initialize_by(deal_id: deal.id, lender_id: lender.id)
        deal_lender.save!
        @lenders << lender
      end
    end
  end

  def send_invitations
    @lenders.each do |lender|
      if lender.pending_account_setup?
        lender.deliver_invitation
      end

      DealMailer.invite_lender(deal: @deal, lender: lender).deliver_later

      LinkBrokerLenderJob.perform_later({ broker_id: Current.user.id, lender_id: lender.id})

      NotificationJob.perform_later({
        "content" => I18n.t('notifications.invited_deal'),
        "user_id" => lender.id,
        "notificable_type": @deal.class.to_s,
        "notificable_id": @deal.id
      })
    end
  end
end
