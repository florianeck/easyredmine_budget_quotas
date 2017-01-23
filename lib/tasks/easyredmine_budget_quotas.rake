namespace :easyredmine_budget_quotas do

  desc "Setup all required custom fields required to for the Budget Quotas Plugin"
  task :install do

    # Add activities
    ## budget
    budget = TimeEntryActivity.find_or_create_by(name: 'Budget', internal_name: 'ebq_budget', ebq_data_type: 'budget')

    ## quota
    quota = TimeEntryActivity.find_or_create_by(name: 'Quota', internal_name: 'ebq_quota', ebq_data_type: 'quota')

    # Time Entry Custom fields
    TimeEntryCustomField.find_or_create_by(name: 'Valid From', internal_name: 'ebq_valid_from', field_format: 'date')
    TimeEntryCustomField.find_or_create_by(name: 'Valid To', internal_name: 'ebq_valid_to', field_format: 'date')
    TimeEntryCustomField.find_or_create_by(name: 'Apply on Budget/Quota',
      internal_name: 'ebq_budget_quota_source', field_format: 'enumeration', possible_values: ['none', 'budget', 'quota']
    )

    TimeEntryCustomField.find_or_create_by(name: 'Source of Budget/Quota', internal_name: 'ebq_budget_quota_id', field_format: 'integer')
    TimeEntryCustomField.find_or_create_by(name: 'Value of Budget/Quota', internal_name: 'ebq_budget_quota_value', field_format: 'float')


  end

end