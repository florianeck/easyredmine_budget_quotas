class MoveToleranceAmountToTimeEntry < ActiveRecord::Migration

  def up
    # check if Custom field 'ebq_budget_quota_tolerance' exists
    if TimeEntryCustomField.find_by(internal_name: 'ebq_budget_quota_tolerance', field_format: 'float').nil?
      Rails.logger.error "TimeEntryCustomField 'ebq_budget_quota_tolerance' is missing. Please run 'rake easyredmine_budget_quotas:install RAILS_ENV=#{Rails.env}'"
    end
    
    # 1. Find existing Budget/Quote Time Entries
    activities = TimeEntryActivity.where(internal_name: ['ebq_budget', 'ebq_quota'])
    time_entries = TimeEntry.where(activity_id: activities)
    
    time_entries.each do |time_entry|
      cf_tolerance  = time_entry.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_tolerance' }
      time_entry.custom_field_values = {cf_tolerance.id => time_entry.project.budget_quotas_tolerance_amount}
      time_entry.save
    end
    
    remove_column :projects, :budget_quotas_tolerance_amount
  end
  
  def down
    add_column :projects, :budget_quotas_tolerance_amount, :integer
  end
end