module DealsHelper
  def deals_status(deals)
    status = {drafts: 0, review: 0, funding: 0, signatures: 0, notary: 0, disbursement: 0, paying: 0}
    deals.each do |deal|
      status[:drafts] += 1 if deal.draft?
      status[:review] += 1 if deal.submitted?
    end

    status
  end

  def deal_terms_in_words(terms_years_months)
    years = terms_years_months[:years]
    months = terms_years_months[:months]

    "#{t('deals.terms.index.terms_in_words.years', count: years)} #{t('deals.terms.index.terms_in_words.months', count: months)}".strip
  end

  def mortgage_rank(deal)
    count = deal.property.mortgages.count

    if deal.terms.type == 'Refinance'
      count = deal.property.mortgages.count - 1
    end

    suffix = case count
             when 0
               'st'
             when 1
               'nd'
             when 2
               'rd'
             else
               'th'
             end
    "#{count <= 0 ? 1 : count + 1}#{suffix}"
  end
end
