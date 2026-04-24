# app/mailers/user_mailer.rb
class DealMailer < ApplicationMailer
  DEFAULT_LEVITAS_EMAIL = 'hello@levita.ai'

  def deal_submitted(deal:, email: DEFAULT_LEVITAS_EMAIL)
    @deal = deal
    mail(to: email, subject: 'A new Deal was Submitted')
  end

  def deal_terms_send(deal:, email:)
    @deal = deal
    mail(to: email, subject: 'Deal was Submitted')
  end

  def deal_terms_rejected(user:, broker_email:, deal_name:)
    @user = user
    @deal_name = deal_name

    email = if user.admin?
      broker_email
    else
      DEFAULT_LEVITAS_EMAIL
    end

    mail(to: email, subject: 'Deal terms were rejected')
  end

  def deal_terms_accepted(deal:, email: DEFAULT_LEVITAS_EMAIL)
    @deal = deal
    mail(to: DEFAULT_LEVITAS_EMAIL, subject: 'Deal terms were accepted')
  end

  def invite_lender(deal:, lender:)
    @deal = deal
    @lender = lender

    mail(to: lender.email, subject: 'You were invited to a deal')
  end

  def lender_committed_capital(deal:, lender:, amount:)
    @deal = deal
    @lender = lender
    @amount = amount

    mail(to: lender.email, subject: 'We have received your investment commitment')
  end

  def lender_signature_reminder(deal:, lender:, amount:)
    @deal = deal
    @lender = lender
    @amount = amount

    mail(to: lender.email, subject: 'We have received your investment commitment')
  end

  def funding_completed(deal:)
    @deal = deal

    mail(to: DEFAULT_LEVITAS_EMAIL, subject: 'Deal funding completed')
  end

  def prefilled_deal(deal:)
    @deal = deal

    mail(to: @deal.user.email, subject: 'Your documents has been analyzed')
  end
end
