class Deals::ApplicantController < Deals::BaseController
  include Wicked::Wizard

  helper_method :wizard_step_path

  steps :information, :income, :assets, :liabilities

  before_action :set_sub_step, only: [:show, :update]

  def show
    case step
    when :information
      @applicant = applicant
    when :income
      @employer = applicant.employer
      @employer&.income&.build_default_item if @employer&.income&.items.empty?
    when :assets
      @assets = applicant.assets
      @assets.build_default_item if @assets.items.empty?
    when :liabilities
      @liabilities = applicant.liabilities
    end

    render_wizard
  end

  def update
    valid = case step
    when :information
      @applicant = Deal::Applicant.new(merge_applicant_params)
      set_applicant(@applicant.serialize)
      @applicant.valid?
    when :income
      @employer = Deal::Employer.new(employer_params)
      applicant.employer = @employer
      set_applicant(applicant.serialize)
      @employer.valid?
    when :assets
      @assets = Deal::Assets.new(assets_params)
      applicant.assets = @assets
      set_applicant(applicant.serialize)
      @assets.valid?
    when :liabilities
      @liabilities = Deal::Liabilities.new(liabilities_params)
      applicant.liabilities = @liabilities
      set_applicant(applicant.serialize)
      @liabilities.valid?
    end

    if valid
      if save_as_draft?
        @deal.save
        redirect_to root_path
      else
        render_wizard(@deal)
      end
    else
      render step
    end
  end

  private
  def applicant
    @deal.applicant
  end

  def set_applicant(applicant)
    @deal.applicant = applicant
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:main_applicant)
  end

  def set_sub_step
    @active_sub_step = @step_builder.set_current_sub_step(step)
  end

  def merge_applicant_params
    applicant.serialize.deep_merge(applicant_params)
  end

  def finish_wizard_path
    deal_secondary_applicant_index_path
  end

  def wizard_step_path(deal, step)
    deal_main_applicant_path(deal, step)
  end

  def applicant_params
    params.require(:deal_applicant).permit(
      :title,
      :first_name,
      :last_name,
      :birth_date,
      :social_insurance_number,
      :email,
      :phone_number,
      address: [
        :street,
        :unit,
        :city,
        :province,
        :country,
        :postal_code
      ]
    )
  end
def employer_params
    params.require(:deal_employer).permit(
      :name,
      :job_title,
      :industry_type,
      :employment_type,
      :duration_years,
      :duration_months,
      :phone_number,
      :fax,
      :email,
      :ext,
      income: [:type, :period, :amount],
      address: [
        :street,
        :unit,
        :city,
        :province,
        :country,
        :postal_code
      ]
    )
  end

  def assets_params
    if params[:deal_assets].present?
      params[:deal_assets][:assets].values
    else
      []
    end
  end

  def liabilities_params
    params.require(:deal_liabilities).permit(
      :taxes,
      :child_support,
      :bankruptcy,
      :bankruptcy_status,
      :expected_release_date,
      :cost_of_release,
      debt_obligations: [:type, :balance_remaining, :monthly_payment],
    )
  end
end
