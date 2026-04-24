class DealStatuses
  attr_reader :user

  PERFORMANCE_STATES = {
    'drafts' => ['draft'],
    'review' => ['submitted', 'reviewed', 'accepted', 'rejected'],
    'funding' =>  ['funding'],
    'signatures' => ['signatures'],
    'notary' => ['notary'],
    'disbursement' => ['disbursement'],
    'paying' => ['payments']
  }

  def initialize(user:)
    @user = user
  end

  def call
    totals = deals.group(:state).count
    format_results(totals)
  end

  private
  def format_results(totals)
    # removes draft and review for lenders
    if @user.lender?
      PERFORMANCE_STATES.delete 'drafts'
      PERFORMANCE_STATES.delete 'review'
    end

    PERFORMANCE_STATES.each_with_object({}) do |performance_states, result|
      state, group_states = performance_states
      result[state] = group_states.map.compact.sum { |single_state| totals[single_state] || 0 }
      # Renames funding to Commited for lenders
      result['commited'] = result.delete('funding') if @user.lender? && state == 'funding'
    end
  end

  def deals
    case @user.role
    when 'admin'
      Deal.all
    when 'broker'
      Deal.where(user: user)
    when 'lender'
      Deal.joins(:deal_lenders).where({deal_lenders: { lender: user }}).where('deal_lenders.commited_capital > ?', 0)
    end
  end
end
