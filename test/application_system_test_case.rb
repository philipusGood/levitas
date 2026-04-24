require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium_chrome_headless, using: :chrome, screen_size: [1400, 1400]

  def login_as(user:, password: "Password123!")
    user.confirm
    visit root_path

    assert_current_path new_user_session_path, wait: 10

    fill_in "user_email", with: user.email
    fill_in "user_password", with: password
    click_on "sign_in"
  end

  def reload
    visit current_url
  end
end
