# spec/deal_builder_spec.rb

require 'rails_helper'

describe DealBuilder do
  let(:builder) { DealBuilder.new }

  describe '#set_current_step' do
    it 'sets the current step' do
      builder.set_current_step(:main_applicant)
      expect(builder.current_step).to eq(:main_applicant)
    end

    it 'raises NotStepFound for invalid step' do
      expect { builder.set_current_step(:invalid_step) }.to raise_error(DealBuilder::NotStepFound)
    end
  end

  describe '#set_current_sub_step' do
    it 'sets the current sub step' do
      builder.set_current_step(:main_applicant)
      builder.set_current_sub_step(:information)
      expect(builder.current_sub_step).to eq(:information)
    end

    it 'raises MissingCurrentStep if current step is not set' do
      expect { builder.set_current_sub_step(:information) }.to raise_error(DealBuilder::MissingCurrentStep)
    end
  end

  describe '#steps' do
    it 'returns the list of steps' do
      expect(builder.steps).to eq([:main_applicant, :secondary_applicant, :guarantor, :property, :deal_terms, :loan_purpose, :documents, :broker_fee, :credit_check, :summary])
    end
  end

  describe '#sub_steps?' do
    it 'returns true if there are sub steps for a step' do
      expect(builder.sub_steps?(:main_applicant)).to be_truthy
    end

    it 'returns false if there are no sub steps for a step' do
      expect(builder.sub_steps?(:property)).to be_falsey
    end
  end

  describe '#subitems_for' do
    it 'returns the sub items for a step' do
      expect(builder.subitems_for(:main_applicant)).to eq([:information, :income, :assets, :liabilities])
    end

    it 'returns an empty array for steps with no sub items' do
      expect(builder.subitems_for(:property)).to eq([])
    end
  end

  describe '#step_index' do
    it 'returns the index of a step' do
      expect(builder.step_index(:secondary_applicant)).to eq(2)
    end
  end

  describe '#last_item?' do
    it 'returns true if the step is the last step' do
      expect(builder.last_item?(:summary)).to be_truthy
    end

    it 'returns false if the step is not the last step' do
      expect(builder.last_item?(:main_applicant)).to be_falsey
    end
  end

  describe '#last_step_subitem?' do
    it 'returns true if the sub item is the last sub item in the step' do
      expect(builder.last_step_subitem?(:main_applicant, :liabilities)).to be_truthy
    end

    it 'returns false if the sub item is not the last sub item in the step' do
      expect(builder.last_step_subitem?(:main_applicant, :assets)).to be_falsey
    end
  end

  describe '#before_current_step?' do
    it 'returns true if the argument step is before the current step' do
      builder.set_current_step(:broker_fee)
      expect(builder.before_current_step?(:deal_terms)).to be_truthy
    end

    it 'returns false if the argument step is after or equal to the current step' do
      builder.set_current_step(:credit_check)
      expect(builder.before_current_step?(:summary)).to be_falsey
      expect(builder.before_current_step?(:credit_check)).to be_falsey
    end
  end

  describe '#before_current_sub_step?' do
    it 'returns true if the argument sub step is before the current sub step' do
      builder.set_current_step(:main_applicant)
      builder.set_current_sub_step(:income)
      expect(builder.before_current_sub_step?(:information)).to be_truthy
    end

    it 'returns false if the argument sub step is after or equal to the current sub step' do
      builder.set_current_step(:main_applicant)
      builder.set_current_sub_step(:income)
      expect(builder.before_current_sub_step?(:income)).to be_falsey
      expect(builder.before_current_sub_step?(:assets)).to be_falsey
    end

    it 'returns nil if current sub step is not set' do
      expect(builder.before_current_sub_step?(:information)).to be_nil
    end
  end
end
