module EasyredmineBudgetQuotas
  module ProjectBudgetQuota

    extend ActiveSupport::Concern

    def query_spent_entries_on(current_entry)
      query = ["SELECT `time_entries`.*, `custom_values`.*, `custom_fields`.*, `easy_money_time_entries_expenses`.`price` as price FROM `time_entries`"]
      query << "INNER JOIN `custom_values` ON `custom_values`.`customized_id` = `time_entries`.`id` AND `custom_values`.`customized_type` = 'TimeEntry'"
      query << "INNER JOIN `custom_fields` on `custom_fields`.`id` = `custom_values`.`custom_field_id`"
      query << "INNER JOIN `easy_money_time_entries_expenses` ON `easy_money_time_entries_expenses`.`time_entry_id` = `time_entries`.`id`"
      query << "WHERE `custom_fields`.`internal_name` = 'ebq_budget_quota_id' AND `custom_values`.`value` = '#{current_entry.id}' AND `time_entries`.`project_id` = #{self.id}"
      query << "AND `easy_money_time_entries_expenses`.`rate_type_id` = #{self.calculation_rate_id}"

      TimeEntry.find_by_sql(query.join(' '))
    end

    def calculation_rate_id
      EasyMoneyRateType.find_by(name: self.budget_quotas_money_rate_type).id
    end

    def get_current_budget_quota_entries(type:, ref_date: Time.now.to_date)
      if @_currently_valied_entries.nil?
        entries = TimeEntry.where(project_id: self.id, activity_id: EasyredmineBudgetQuotas.send("#{type}_entry_activities").ids, entity_type: 'Project', easy_locked: true)
          .where.not(budget_quota_exceeded: true)
        @_currently_valied_entries = entries.select do |e|
          (e.valid_to && e.valid_to > ref_date) && (e.valid_from && e.valid_from < ref_date)
        end.sort_by do |e|
          e.valid_from
        end
      end
      return @_currently_valied_entries
    end

  end
end