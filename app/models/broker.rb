class Broker < User
  has_many :broker_lenders, dependent: :destroy
  has_many :lenders, through: :broker_lenders

  default_scope { where(role: :broker) }

  after_initialize :set_default_role

  private

  def password_required?
    return false if skip_password_validation
    super
  end

  def set_default_role
    self.role ||= :broker
  end
end
