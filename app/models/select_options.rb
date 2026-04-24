class SelectOptions
  PROFILE_TITLES = [
    'Mr',
    'Mrs',
    'Miss',
    'Ms'
  ]

  CANADIAN_PROVIENCES = [
    "Alberta",
    "British Columbia",
    "Manitoba",
    "New Brunswick",
    "Newfoundland and Labrador",
    "Nova Scotia",
    "Ontario",
    "Prince Edward Island",
    "Quebec",
    "Saskatchewan"
  ]

  INDUSTRY_TYPE = [
    "Agriculture & Forestry",
    "Arts, Entertainment & Recreation",
    "Automotive",
    "Banking & Finance",
    "Construction",
    "Consumer Goods",
    "Education",
    "Energy & Utilities",
    "Food & Beverages",
    "Healthcare & Pharmaceuticals",
    "Hospitality & Tourism",
    "Information Technology & Services",
    "Insurance",
    "Manufacturing",
    "Media & Communications",
    "Mining & Metals",
    "Non-Profit & Charity",
    "Professional Services (e.g., law, accounting)",
    "Public Administration & Government",
    "Real Estate",
    "Retail",
    "Transportation & Logistics",
    "Wholesale",
    "Others"
  ]

  EMPLOYMENT_TYPE = [
    "Full-Time",
    "Part-Time",
    "Temporary",
    "Contract",
    "Self-Employed",
    "Commission-based"
  ]

  ASSET_TYPE = [
    "Real Estate",
    "Vehicles",
    "Cash & Bank Accounts",
    "Stocks & Bonds",
    "Retirement Accounts",
    "Business Interests/Ownership",
    "Personal Property",
    "Other"
  ]

  PROPERTY_TYPE = [
    "Detached House",
    "Semi-Detached House",
    "Townhouse",
    "Condominium",
    "Duplex",
    "Triplex",
    "Fourplex",
    "Multifamily",
    "Mobile Home",
    "Vacant Land",
    "Cottage/Recreational",
    "Commercial Property",
    "Industrial",
    "Agricultural/Farm Land",
    "Mixed-Use Property",
    "Other"
  ]

  MORTAGE_TYPE = [
    "Property Purchase",
    "Refinance",
    "Second Mortgage",
    "Mortgage Renewal",
    "Mortgage Assumption"
  ]

  AMORTIZATION_PERIOD = [
    "Interest Only",
    "1 Year",
    "2 Years",
    "3 Years",
    "4 Years",
    "5 Years",
    "10 Years",
    "15 Years",
    "20 Years",
    "25 Years",
    "30 Years"
  ]

  INCOME_PERIOD = [
    "Weekly",
    "Bi-Weekly (Every Two Weeks)",
    "Semi-Monthly (Twice a Month)",
    "Monthly",
    "Quarterly",
    "Semi-Annually (Every Six Months)",
    "Annually"
  ]

  INCOME_TYPE = [
    "Employment Income",
    "Business/Professional Income (Self-employed earnings)",
    "Rental Income",
    "Dividends and Interest Income",
    "Private Pension",
    "Social Security or Retirement Benefits (Government)",
    "Unemployment Benefits",
    "Child Support/Alimony",
    "Investment Returns (Capital Gains)",
    "Trust Income"
  ]

  FILTER_DEALS = [
    [I18n.t('dashboard.index.deals_filter.all'), "all"],
    [I18n.t('dashboard.index.deals_filter.active'), "active"],
    [I18n.t('dashboard.index.deals_filter.closed'), "closed"],
    [I18n.t('dashboard.index.deals_filter.draft'), "draft"]
  ]

  FILTER_DEALS_LENDER = [
    [I18n.t('dashboard.index.deals_filter.all'), "all"],
    [I18n.t('dashboard.index.deals_filter.active'), "active"],
    [I18n.t('dashboard.index.deals_filter.finished'), "closed"]
  ]

  SORT_DEALS = {
    closing_date: 'closing-date',
    amount: 'amount'
  }

  DEAL_CLOSING_DATE = [
    ['None', ''],
    [I18n.t('deals.partials.filters.within_next_days', days: 30), '30'],
    [I18n.t('deals.partials.filters.within_next_days', days: 60), '60'],
    [I18n.t('deals.partials.filters.within_next_days', days: 90), '90'],
    [I18n.t('deals.partials.filters.within_next_days', days: '90+'), '90+']
  ]

  CANADA_PROVINCES = [
    ['Alberta', 'AB'],
    ['British Columbia', 'BC'],
    ['Manitoba', 'MB'],
    ['New Brunswick', 'NB'],
    ['Newfoundland and Labrador', 'NL'],
    ['Nova Scotia', 'NS'],
    ['Ontario', 'ON'],
    ['Prince Edward Island', 'PE'],
    ['Quebec', 'QC'],
    ['Saskatchewan', 'SK']
  ]

  LOAN_TYPES = [
    "Credit Card",
    "Student Loan",
    "Personal Loan",
    "Car Credit",
    "Mortgage Payment",
    "Other Loan",
  ]

  PAYMENT_FRECUENCY = [
    "Weekly",
    "Bi-Weekly",
    "Monthly",
    "Prepaid"
  ]
end
