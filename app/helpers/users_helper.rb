module UsersHelper
  def status(user)
    if !user.pending_account_setup?
      if current_user.admin? && user.lender? && user.approved_at.nil?
        button_to approve_lender_lender_path(user), class: "text-blue-500 hover:text-blue-400", data: { turbo: false } do
          t('.accept_lender')
        end
      else
        content_tag :span, 'Active', class: 'text-green-600'
      end
    elsif user.invitation_sent_at.present?
      "Invited #{time_ago_in_words(user.invitation_sent_at)}"
    else
      content_tag :span, 'Pending', class: 'text-gray-600'
    end
  end
end