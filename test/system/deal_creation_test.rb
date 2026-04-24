require "application_system_test_case"

class DealCreatinTest < ApplicationSystemTestCase
  test "broker should be able to create mortage deals" do
    password = "Password1234!"
    user = FactoryBot.create(:user, role: 'broker', password: password, password_confirmation: password)
    user.confirm
    visit root_path

    assert_current_path new_user_session_path, wait: 10

    fill_in "user_email", with: user.email
    fill_in "user_password", with: password
    click_on "sign_in"


    sleep(1)
    visit dashboard_index_path

    click_on "create-deal"

    # Main Applicant

    # Information
    fill_in "deal_applicant_first_name", with: "Arturo"
    fill_in "deal_applicant_last_name", with: "Diaz"
    page.execute_script("document.getElementById('deal_applicant_birth_date').value = '1994-02-23';")
    fill_in "deal_applicant_social_insurance_number", with: "#{Faker::Number.between(from: 100, to: 999)}-#{Faker::Number.between(from: 100, to: 999)}-#{Faker::Number.between(from: 100, to: 999)}"
    fill_in "deal_applicant_email", with: "arturo@levitas.ai"
    fill_in "deal_applicant_phone_number", with: "3241445105"
    fill_in "deal_applicant_address_street", with: "365 King ST"
    fill_in "deal_applicant_address_street", with: "18"
    fill_in "deal_applicant_address_city", with: "Toronto"
    fill_in "deal_applicant_address_postal_code", with: "M5V 3L9"
    click_on "continue-button"

    # Employer
    fill_in "deal_employer_name", with: "Levitas"
    fill_in "deal_employer_job_title", with: "Broker"
    fill_in "deal_employer_duration_years", with: "2"
    fill_in "deal_employer_duration_months", with: "1"
    fill_in "deal_employer_income__amount", with: "60000"
    fill_in "deal_employer_address_street", with: "365 King ST"
    fill_in "deal_employer_address_street", with: "18"
    fill_in "deal_employer_address_city", with: "Toronto"
    fill_in "deal_employer_address_postal_code", with: "M5V 3L9"
    fill_in "deal_employer_phone_number", with: "2341330410"
    click_on "continue-button"

    # Assets
    select 'Vehicles', from: 'deal_assets_assets_0__type'
    fill_in 'deal_assets_assets_0__description', with: "Tesla X"
    fill_in "deal_assets_assets_0__amount", with: "60000"
    click_on "add-asset"

    select 'Real Estate', from: 'deal_assets_assets_1__type'
    fill_in 'deal_assets_assets_1__description', with: "House in Toronto"
    fill_in "deal_assets_assets_1__amount", with: "60000"
    check 'deal_assets_assets_1__mortage'
    sleep(1)

    select 'Townhouse', from: 'deal_assets_assets_1__property_type'
    fill_in 'deal_assets_assets_1__balance_remaining', with: "1000"
    fill_in 'deal_assets_assets_1__monthly_payment', with: "2000"

    click_on "continue-button"


    # Liabilities
    click_on "add-liability"
    fill_in "deal_liabilities_debt_obligations__balance_remaining", with: "10000"
    fill_in "deal_liabilities_debt_obligations__monthly_payment", with: "100"

    fill_in "deal_liabilities_taxes", with: "0"
    fill_in "deal_liabilities_child_support", with: "0"
    choose "deal_liabilities_bankruptcy_true"
    sleep(1)
    choose "deal_liabilities_bankruptcy_status_true"
    sleep(1)
    page.execute_script("document.getElementById('deal_liabilities_expected_release_date').value = '2025-02-23';")
    fill_in "deal_liabilities_cost_of_release", with: "1000"
    click_on "continue-button"

    # Secondary Applicant

    click_on "add-secondary-applicant"

    # Information
    fill_in "deal_applicant_first_name", with: "Arturo"
    fill_in "deal_applicant_last_name", with: "Diaz"
    page.execute_script("document.getElementById('deal_applicant_birth_date').value = '1994-02-23';")
    fill_in "deal_applicant_social_insurance_number", with: "#{Faker::Number.between(from: 100, to: 999)}-#{Faker::Number.between(from: 100, to: 999)}-#{Faker::Number.between(from: 100, to: 999)}"
    fill_in "deal_applicant_email", with: "arturo@levitas.ai"
    fill_in "deal_applicant_phone_number", with: "3241445105"
    fill_in "deal_applicant_address_street", with: "365 King ST"
    fill_in "deal_applicant_address_street", with: "18"
    fill_in "deal_applicant_address_city", with: "Toronto"
    fill_in "deal_applicant_address_postal_code", with: "M5V 3L9"
    click_on "continue-button"

    # Employer
    fill_in "deal_employer_name", with: "Levitas"
    fill_in "deal_employer_job_title", with: "Broker"
    fill_in "deal_employer_duration_years", with: "2"
    fill_in "deal_employer_duration_months", with: "1"
    fill_in "deal_employer_income__amount", with: "60000"
    fill_in "deal_employer_address_street", with: "365 King ST"
    fill_in "deal_employer_address_street", with: "18"
    fill_in "deal_employer_address_city", with: "Toronto"
    fill_in "deal_employer_address_postal_code", with: "M5V 3L9"
    fill_in "deal_employer_phone_number", with: "2341330410"
    click_on "continue-button"

    # Assets
    select 'Vehicles', from: 'deal_assets_assets_0__type'
    fill_in 'deal_assets_assets_0__description', with: "Tesla X"
    fill_in "deal_assets_assets_0__amount", with: "60000"
    click_on "add-asset"

    select 'Real Estate', from: 'deal_assets_assets_1__type'
    fill_in 'deal_assets_assets_1__description', with: "House in Toronto"
    fill_in "deal_assets_assets_1__amount", with: "60000"
    check 'deal_assets_assets_1__mortage'
    sleep(1)

    select 'Townhouse', from: 'deal_assets_assets_1__property_type'
    fill_in 'deal_assets_assets_1__balance_remaining', with: "1000"
    fill_in 'deal_assets_assets_1__monthly_payment', with: "2000"

    click_on "continue-button"


    # Liabilities
    fill_in "deal_liabilities_taxes", with: "0"
    fill_in "deal_liabilities_child_support", with: "0"
    choose "deal_liabilities_bankruptcy_true"
    sleep(1)
    choose "deal_liabilities_bankruptcy_status_true"
    sleep(1)
    page.execute_script("document.getElementById('deal_liabilities_expected_release_date').value = '2025-02-23';")
    fill_in "deal_liabilities_cost_of_release", with: "1000"
    click_on "continue-button"


    # Guarantor
    check "deal_guarantor_confirmation"
    sleep(1)
    fill_in "deal_guarantor_first_name", with: "Jesus"
    fill_in "deal_guarantor_last_name", with: "Zavala"
    fill_in "deal_guarantor_email", with: "jesus.zavala@gmail.com"
    fill_in "deal_guarantor_phone_number", with: "31230010293"
    fill_in "deal_guarantor_address_street", with: "365 King ST"
    fill_in "deal_guarantor_address_street", with: "18"
    fill_in "deal_guarantor_address_city", with: "Toronto"
    fill_in "deal_guarantor_address_postal_code", with: "M5V 3L9"
    click_on "continue-button"

    # Property
    fill_in "deal_property_mls_number", with: "12345"
    fill_in "deal_property_price", with: "1000"
    page.execute_script("document.getElementById('deal_property_approximate_closing_date').value = '2025-02-23';")
    fill_in "deal_property_address_street", with: "365 King ST"
    fill_in "deal_property_address_street", with: "18"
    fill_in "deal_property_address_city", with: "Toronto"
    fill_in "deal_property_address_postal_code", with: "M5V 3L9"
    click_on "continue-button"


    # Deal Terms
    fill_in "deal_term_mortgage_principal", with: "70000"
    fill_in "deal_term_lenders_fee", with: "2"
    fill_in "deal_term_interest_rate", with: "2"
    fill_in "deal_term_terms", with: "12"
    click_on "continue-button"

    # Loan Purpose
    fill_in "deal_loan_purpose_funds_usage", with: "The borrower intends to use the loan proceeds to renovate the property, increase its market value, and attract potential buyers."
    fill_in "deal_loan_purpose_exit_strategy", with: "The borrower plans to refinance the loan with a conventional lender upon completion of the renovations, ensuring timely repayment and maximizing returns on the investment."
    click_on "continue-button"

    # Documents
    click_on "continue-button"

    # Broker Fees
    click_on "continue-button"

    # Credit Check
    check "deal_credit_check_accept_terms"
    click_on "continue-button"

    # Summary
    click_on "continue-button"
  end
end
