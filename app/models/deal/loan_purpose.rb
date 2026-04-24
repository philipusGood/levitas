class Deal::LoanPurpose < Deal::Base
  attr_accessor :funds_usage, :exit_strategy

  validates :funds_usage, presence: true
  validates :exit_strategy, presence: true

  def initialize(attributes = {})
    super()

    puts attributes
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

    @funds_usage = attributes[:funds_usage]
    @exit_strategy = attributes[:exit_strategy]
  end

  def serialize
    {
      funds_usage: funds_usage,
      exit_strategy: exit_strategy,
    }
  end
end
