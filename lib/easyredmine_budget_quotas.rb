module EasyredmineBudgetQuotas

  class << self

    def budget_entry_activities
      TimeEntryActivity.where(ebq_data_type: 'budget')
    end

    def quota_entry_activities
      TimeEntryActivity.where(ebq_data_type: 'quota')
    end
    
    def get_available_budget_quotas_for_time_entry_ids(time_entry_ids, options = {required_min_budget_value: 1})
      activity_ids = (budget_entry_activities + quota_entry_activities).map(&:id)
      selected_time_entries = TimeEntry.where(id: time_entry_ids).where.not(activity_id: activity_ids)
      
      projects = Project.where(id: selected_time_entries.pluck(:project_id).uniq)
      project_ids = projects.map {|p| p.self_and_ancestors.map(&:id) }.flatten.uniq
      options[:required_min_budget_value] ||= 1
      
      bq_time_entries = TimeEntry.where(project_id: project_ids, activity_id: activity_ids, easy_locked: true).where.not(budget_quota_exceeded: true) 
      
      dates = selected_time_entries.pluck(:spent_on)
      ref_min = dates.min
      ref_max = dates.max
      
      activity_ids_for_selected_entries = selected_time_entries.pluck(:activity_id).uniq
      
      bq_time_entries.select do |e|
        
        (e.valid_from && e.valid_from <= ref_min) && 
        (e.valid_to && e.valid_to >= ref_max) && 
        ((e.remaining_value + e.budget_quotas_tolerance_amount) > options[:required_min_budget_value]) &&
        (activity_ids_for_selected_entries - (e.send :ebq_custom_field_value, 'ebq_budget_quota_app_activity').map(&:to_i)).empty?
      end.sort_by do |e|
        e.valid_from
      end
    end
    
  end

end