namespace :easyredmine_budget_quotas do

  desc "Setup all required custom fields required to for the Budget Quotas Plugin"
  task :install => :environment do

    # Add activities
    ## budget
    budget = TimeEntryActivity.find_or_initialize_by(name: 'Budget', internal_name: 'ebq_budget', ebq_data_type: 'budget', allow_time_entry_zero_hours: true)

    ## quota
    quota = TimeEntryActivity.find_or_initialize_by(name: 'Quota', internal_name: 'ebq_quota', ebq_data_type: 'quota', allow_time_entry_zero_hours: true)

    # make shure hours get hidden
    [budget, quota].each do |e|
      puts "CHECKING required custom field '#{e.name}'" 
      if e.new_record?
        e.save
        puts "  CREATING new custom field with id '#{e.id}'"
      else
        puts "  FOUND matching custom field with id '#{e.id}'"
      end
      e.update_column(:akquinet_hide_hours, true)
    end

    # Time Entry Custom fields
    entries = []
    entries << TimeEntryCustomField.find_or_initialize_by(name: 'Valid From', internal_name: 'ebq_valid_from', field_format: 'date')
    entries << TimeEntryCustomField.find_or_initialize_by(name: 'Valid To', internal_name: 'ebq_valid_to', field_format: 'date')
    entries << TimeEntryCustomField.find_or_initialize_by(name: 'Value of Budget/Quota', internal_name: 'ebq_budget_quota_value', field_format: 'float')
    
    entries << TimeEntryCustomField.find_or_initialize_by(name: 'Budget Quoate Tolerance Amount',
      internal_name: 'ebq_budget_quota_tolerance', field_format: 'float'
    )
    
    custom_field_for_activity = TimeEntryCustomField.find_or_initialize_by(name: 'Budget Quote applicable for',
      internal_name: 'ebq_budget_quota_app_activity', field_format: 'easy_lookup', multiple: true
    )
    
    if custom_field_for_activity.persisted?
      puts "PROCEED with existing 'TimeEntryCustomField(#{custom_field_for_activity.id})'"
    else
      custom_field_for_activity.save
      puts "CREATE required 'TimeEntryCustomField(#{custom_field_for_activity.id})'"
    end
    
    puts "  sSETTING required data for 'TimeEntryCustomField(#{custom_field_for_activity.id})'"
    custom_field_for_activity.settings = {"entity_type":"TimeEntryActivity","entity_attribute":"name"}
    custom_field_for_activity.save
    
    entries << custom_field_for_activity
    
    entries.each do |e|
      puts "SETTING DATA for 'TimeEntryCustomField(#{e.id})'"
      e.activity_ids = (e.activity_ids + [budget.id, quota.id]).uniq
      puts "  ACTIVITIES for '#{e.name}' IS NOW: #{e.activities.map(&:name).join(',')}"
      e.visible = false
      e.is_primary = false
      puts "  => #{e.attributes.slice('visible', 'is_primary')}"  
      e.save
    end

    # make sure all values are always set as required
    source_of = TimeEntryCustomField.find_or_initialize_by(name: 'Source of Budget/Quota', internal_name: 'ebq_budget_quota_id')
    
    if source_of.new_record?
      puts "CREATE new source of budget/quota entry"
      if source_of.save
        puts "SUCCESFULLY saved 'TimeEntryCustomField(#{source_of.id})'"
      else
        raise "sth went wrong"
      end
    else
      puts "PROCEED with existing entry for #{source_of.internal_name}: 'TimeEntryCustomField(#{source_of.id})' "
    end
    
    source_of.assign_attributes(visible: true, editable: false, is_primary: false, non_editable: true, is_filter: true)
    source_of.field_format = 'easy_lookup'
    source_of.settings = {"entity_type":"TimeEntry","entity_attribute":"comment_link"}
    if source_of.save
      # field-format cant be assigned, to make sure older versions upgrade correctly, 'update_column' is used to force it
      source_of.update_column(:field_format, 'easy_lookup') unless source_of.field_format == 'easy_lookup'
      puts "ASSIGN all required settings for #{source_of.internal_name} to: 'TimeEntryCustomField(#{source_of.id})'"
    else
      raise "sth went wrong"
    end
    
    apply_on = TimeEntryCustomField.find_or_initialize_by(name: 'Apply on Budget/Quota',
      internal_name: 'ebq_budget_quota_source', field_format: 'value_tree'
    )
    
    if apply_on.new_record?
      puts "CREATE new source of Apply on Budget/Quota"
      if apply_on.save
        puts "SUCCESFULLY saved 'TimeEntryCustomField(#{apply_on.id})'"
      else
        raise "sth went wrong"
      end
    else
      puts "PROCEED with existing entry for #{apply_on.internal_name}: 'TimeEntryCustomField(#{apply_on.id})' "
    end
    
    
    apply_on.update_attributes(visible: false, editable: false, is_primary: false, non_editable: true, possible_values: ['budget', 'quota'])
    
    puts "ASSIGN all required settings for #{apply_on.internal_name} to: 'TimeEntryCustomField(#{apply_on.id})'"
    
    
  end

end