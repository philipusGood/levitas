class Deals::SecondaryApplicantController < Deals::ApplicantController
  before_action :complete_applicant, only: [:index]
  before_action :hide_sub_steps, only: [:index]

  def index
    if params[:draft].present?
      redirect_to root_path
    end
  end

  private
  def set_active_step
    @active_step = @step_builder.set_current_step(:secondary_applicant)
  end

  def applicant
    @deal.secondary_applicant
  end

  def set_applicant(applicant)
    @deal.secondary_applicant = applicant
  end

  def wizard_step_path(deal, step)
    deal_secondary_applicant_path(deal, step)
  end

  def finish_wizard_path
    deal_guarantor_index_path
  end

  def complete_applicant
    redirect_to deal_secondary_applicant_path(@deal, 'information') if @deal.details['secondary_applicant'].present?
  end

  def hide_sub_steps
    @step_builder.show_sub_steps = false
  end
end
