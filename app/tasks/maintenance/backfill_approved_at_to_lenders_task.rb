# frozen_string_literal: true

module Maintenance
  class BackfillApprovedAtToLendersTask < MaintenanceTasks::Task
    def collection
      User.lender
    end

    def process(lender)
      lender.update(approved_at: Time.now)
    end
  end
end
