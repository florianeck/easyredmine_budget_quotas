module EasyredmineBudgetQuotas

  class << self

    def budget_entry_activities
      TimeEntryActivity.where(ebq_data_type: 'budget')
    end

    def quota_entry_activities
      TimeEntryActivity.where(ebq_data_type: 'quota')
    end

  end

end