namespace :easyredmine_budget_quotas do

  desc "Setup all required custom fields required to for the Budget Quotas Plugin"
  task :install => :environment do

    # Add activities
    ## budget
    budget = TimeEntryActivity.find_or_create_by(name: 'Budget', internal_name: 'ebq_budget', ebq_data_type: 'budget', allow_time_entry_zero_hours: true)

    ## quota
    quota = TimeEntryActivity.find_or_create_by(name: 'Quota', internal_name: 'ebq_quota', ebq_data_type: 'quota', allow_time_entry_zero_hours: true)

    # make shure hours get hidden
    [budget, quota].each {|e| e.update_column(:akquinet_hide_hours, true)}

    # Time Entry Custom fields
    entries = []
    entries << TimeEntryCustomField.find_or_create_by(name: 'Valid From', internal_name: 'ebq_valid_from', field_format: 'date')
    entries << TimeEntryCustomField.find_or_create_by(name: 'Valid To', internal_name: 'ebq_valid_to', field_format: 'date')
    entries << TimeEntryCustomField.find_or_create_by(name: 'Value of Budget/Quota', internal_name: 'ebq_budget_quota_value', field_format: 'float')
    
    entries << TimeEntryCustomField.find_or_create_by(name: 'Budget Quoate Tolerance Amount',
      internal_name: 'ebq_budget_quota_tolerance', field_format: 'float'
    )
    
    custom_field_for_activity = TimeEntryCustomField.find_or_initialize_by(name: 'Budget Quote applicable for',
      internal_name: 'ebq_budget_quota_app_activity', field_format: 'easy_lookup', multiple: true
    )
    
    custom_field_for_activity.settings = {"entity_type":"TimeEntryActivity","entity_attribute":"name"}
    custom_field_for_activity.save
    
    entries << custom_field_for_activity
    
    entries.each do |e|
      e.activity_ids = (e.activity_ids + [budget.id, quota.id]).uniq
      e.visible = false
      e.is_primary = false
      e.save
    end

    # make sure all values are always set as required
    source_of = TimeEntryCustomField.find_or_create_by(name: 'Source of Budget/Quota', internal_name: 'ebq_budget_quota_id')
    source_of.assign_attributes(visible: true, editable: false, is_primary: false, non_editable: true)
    source_of.field_format = 'easy_lookup'
    source_of.settings = {"entity_type":"TimeEntry","entity_attribute":"comment_link"}
    source_of.save
    # field-format cant be assigned, to make sure older versions upgrade correctly, 'update_column' is used to force it
    source_of.update_column(:field_format, 'easy_lookup') unless source_of.field_format == 'easy_lookup'
    
    apply_on = TimeEntryCustomField.find_or_create_by(name: 'Apply on Budget/Quota',
      internal_name: 'ebq_budget_quota_source', field_format: 'value_tree'
    )
    apply_on.update_attributes(visible: false, editable: false, is_primary: false, non_editable: true, possible_values: ['budget', 'quota'])
    
    
    
  end

end