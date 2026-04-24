class LenderMailer < ApplicationMailer
  def approval_request(user:)
    @user = user
    mail(to: user.email, subject: 'Your account is ready')
  end
end
