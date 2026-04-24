class LenderMailerPreview < ActionMailer::Preview
  def approval_request
    LenderMailer.approval_request(user: User.first)
  end
end
