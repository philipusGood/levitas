class LendersFetcher
  def initialize
  end

  def call
    raise 'Missing Current User' if Current.user.nil?

    case Current.user.role
    when "admin"
      Lender.all
    when "broker"
      broker = Current.user.becomes(Broker)
      broker.lenders
    end
  end
end
