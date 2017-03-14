namespace :easyredmine_budget_quotas do

  desc "Setup all required custom fields required to for the Budget Quotas Plugin"
  task :install => :environment do

    # Add activities
    ## budget
    budget = TimeEntryActivity.find_or_create_by(name: 'Budget', internal_name: 'ebq_budget', ebq_data_type: 'budget', allow_time_entry_zero_hours: true)

    ## quota
    quota = TimeEntryActivity.find_or_create_by(name: 'Quota', internal_name: 'ebq_quota', ebq_data_type: 'quota', allow_time_entry_zero_hours: true)

    # Time Entry Custom fields
    entries = []
    entries << TimeEntryCustomField.find_or_create_by(name: 'Valid From', internal_name: 'ebq_valid_from', field_format: 'date')
    entries << TimeEntryCustomField.find_or_create_by(name: 'Valid To', internal_name: 'ebq_valid_to', field_format: 'date')
    entries << TimeEntryCustomField.find_or_create_by(name: 'Value of Budget/Quota', internal_name: 'ebq_budget_quota_value', field_format: 'float')

    entries.each do |e|
      e.activity_ids = e.activity_ids + [budget.id, quota.id]
      e.visible = false
      e.save
    end

    TimeEntryCustomField.find_or_create_by(name: 'Source of Budget/Quota', internal_name: 'ebq_budget_quota_id', field_format: 'int', visible: false)

    TimeEntryCustomField.find_or_create_by(name: 'Apply on Budget/Quota',
      internal_name: 'ebq_budget_quota_source', field_format: 'value_tree', possible_values: ['budget', 'quota']
    )

  end

end