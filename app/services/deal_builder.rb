class DealBuilder
  class NotStepFound < StandardError; end
  class MissingCurrentStep < StandardError; end


  attr_accessor :current_step
  attr_accessor :current_sub_step
  attr_accessor :show_sub_steps

  def initialize
    @show_sub_steps = true
  end

  def set_current_step(step)
    raise NotStepFound if !step_source.include?(step)
    @current_step = step
  end

  def set_current_sub_step(step)
    raise MissingCurrentStep if current_step.nil?
    raise NotStepFound if !subitems_for(current_step).present? && subitems_for(current_step).include?(step)

    @current_sub_step = step
  end

  def steps
    step_source.keys
  end

  def admin_steps
    step_source.keys.reject do |step|
      step == :summary
    end + [:property_details]
  end

  def sub_steps?(item)
    step_source[item].present?
  end

  def subitems_for(step)
    step_source[step] || []
  end

  def step_index(step)
    steps.index(step) + 1
  end

  def last_item?(step)
    step_index(step) == step_source.count
  end

  def last_step_subitem?(step, subitem)
    subitems_for(step).last == subitem
  end

  def before_current_step?(step)
    step_index(current_step) > step_index(step)
  end


  def before_current_sub_step?(step)
    return if current_sub_step.nil?
    subitems = subitems_for(current_step)
    subitems.index(current_sub_step) > subitems.index(step)
  end

  private

  def step_source
    if Flipper.enabled?(:ai_documents, Current.user)
      new_step_source
    else
      old_step_source
    end
  end

  def new_step_source
    {
      documents: [],
      main_applicant: [
        :information,
        :income,
        :assets,
        :liabilities,
      ],
      secondary_applicant: [
        :information,
        :income,
        :assets,
        :liabilities,
      ],
      guarantor: [],
      property: [],
      deal_terms: [],
      loan_purpose: [],
      broker_fee: [],
      credit_check: [],
      summary: [],
    }
  end

  def old_step_source
    {
      main_applicant: [
        :information,
        :income,
        :assets,
        :liabilities,
      ],
      secondary_applicant: [
        :information,
        :income,
        :assets,
        :liabilities,
      ],
      guarantor: [],
      property: [],
      deal_terms: [],
      loan_purpose: [],
      documents: [],
      broker_fee: [],
      credit_check: [],
      summary: [],
    }
  end
end
