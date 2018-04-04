module EasyredmineBudgetQuotas
  module ProjectBudgetQuota

    extend ActiveSupport::Concern


    def ebq_rate_type_settings=(val)
      if val.is_a?(Hash)
        self[:ebq_rate_type_settings] = YAML::dump(val)
      end
    end

    def ebq_rate_type_settings
      if self[:ebq_rate_type_settings].present?
        YAML::load(self[:ebq_rate_type_settings])
      else
        {}
      end
    end

    def query_spent_entries_on(current_entry)
      query = ["SELECT `time_entries`.*, `custom_values`.*, `custom_fields`.*, `easy_money_time_entries_expenses`.`price` as price FROM `time_entries`"]
      query << "INNER JOIN `custom_values` ON `custom_values`.`customized_id` = `time_entries`.`id` AND `custom_values`.`customized_type` = 'TimeEntry'"
      query << "INNER JOIN `custom_fields` on `custom_fields`.`id` = `custom_values`.`custom_field_id`"
      query << "INNER JOIN `easy_money_time_entries_expenses` ON `easy_money_time_entries_expenses`.`time_entry_id` = `time_entries`.`id`"
      query << "WHERE `custom_fields`.`internal_name` = 'ebq_budget_quota_id' AND `custom_values`.`value` = '#{current_entry.id}' AND `time_entries`.`project_id` = #{self.id}"
      query << "AND time_entries.activity_id NOT IN (#{(EasyredmineBudgetQuotas.budget_entry_activities.ids + EasyredmineBudgetQuotas.quota_entry_activities.ids).join(",")})"
      query << "AND `easy_money_time_entries_expenses`.`rate_type_id` = #{self.calculation_rate_id}"

      TimeEntry.find_by_sql(query.join(' '))
    end

    def calculation_rate_id
      EasyMoneyRateType.find_by(name: self.budget_quotas_money_rate_type).id
    end

    

  end
end