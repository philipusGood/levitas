# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe BackfillUrlCodeTask do
    describe "#process" do
      subject(:process) { described_class.process(deal) }
      let(:deal) { create(:deal) }

      before do
        deal.update(url_code: nil)
      end

      it "creates url codes for deal" do
        process

        expect(deal.reload.url_code).to_not be_nil
      end
    end
  end
end
