module EasyredmineBudgetQuotas
  module ProjectBudgetQuota

    extend ActiveSupport::Concern

    included do

    end


    def budget_entry_currently_valid
      get_budget_quota_entries_currently_valid(type: :budget)
    end

    def quota_entry_currently_valid
      get_budget_quota_entries_currently_valid(type: :quota)
    end

    def get_budget_quota_entries_currently_valid(type:)
      entries = TimeEntry.where(project_id: self.id, activity_id: EasyredmineBudgetQuotas.send("#{type}_entry_activities").ids, entity_type: 'Project', easy_locked: true)
      currently_valied_entries = entries.select do |e|
        (e.valid_to && e.valid_to > Time.now.to_date) && (e.valid_from && e.valid_from < Time.now.to_date)
      end

      return currently_valied_entries.first
    end

  end
end