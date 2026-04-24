# frozen_string_literal: true

module Maintenance
  class BackfillUrlCodeTask < MaintenanceTasks::Task
    def collection
      Deal.all
    end

    def process(deal)
      if deal.url_code.nil?
        url_code = loop do
          random_code = SecureRandom.alphanumeric.upcase.gsub(/\d/, '')
          break random_code unless Deal.exists?(url_code: random_code)
        end

        deal.url_code = url_code
        deal.save
      end
    end
  end
end
