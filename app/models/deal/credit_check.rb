class Deal::CreditCheck < Deal::Base
  attr_accessor :accept_terms

  validates :accept_terms, acceptance: true

  def initialize(attributes)
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)
    @accept_terms = attributes[:accept_terms]
  end

  def serialize
    {
      accept_terms: accept_terms
    }
  end
end