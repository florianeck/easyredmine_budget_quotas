module EasyredmineBudgetQuotas
  module ProjectBudgetQuota

    extend ActiveSupport::Concern

    included do

    end

    def query_spent_entries_on(type:, ref_date:)
      current_entry = get_current_budget_quota_entry(type: type, ref_date: ref_date)

      if current_entry
        query = ["SELECT `time_entries`.*, `custom_values`.*, `custom_fields`.*, `easy_money_time_entries_expenses`.`price` as price FROM `time_entries`"]
        query << "INNER JOIN `custom_values` ON `custom_values`.`customized_id` = `time_entries`.`id` AND `custom_values`.`customized_type` = 'TimeEntry'"
        query << "INNER JOIN `custom_fields` on `custom_fields`.`id` = `custom_values`.`custom_field_id`"
        query << "INNER JOIN `easy_money_time_entries_expenses` ON `easy_money_time_entries_expenses`.`time_entry_id` = `time_entries`.`id`"
        query << "WHERE `custom_fields`.`internal_name` = 'ebq_budget_quota_source' AND `custom_values`.`value` = '#{type}' AND `time_entries`.`spent_on` BETWEEN '#{current_entry.valid_from}' AND '#{current_entry.valid_to}' AND `time_entries`.`project_id` = #{self.id}"
        query << "AND `easy_money_time_entries_expenses`.`rate_type_id` = #{self.calculation_rate_id}"
        TimeEntry.find_by_sql(query.join(' '))
      else
        []
      end
    end

    def calculation_rate_id
      EasyMoneyRateType.find_by(name: 'internal').id
    end

    def current_budget_value
      current_budget_entry.try(:budget_quota_value)
    end

    def current_quota_value
      current_quota_entry.try(:budget_quota_value)
    end

    def current_budget_entry_valid?
      current_budget_entry.try(:easy_locked?)
    end

    def current_quota_entry_valid?
      current_quota_entry.try(:easy_locked?)
    end

    def get_current_budget_quota_entry(type:, ref_date: Time.now.to_date)
      entries = TimeEntry.where(project_id: self.id, activity_id: EasyredmineBudgetQuotas.send("#{type}_entry_activities").ids, entity_type: 'Project')
      currently_valied_entries = entries.select do |e|
        (e.valid_to && e.valid_to > ref_date) && (e.valid_from && e.valid_from < ref_date)
      end

      return currently_valied_entries.first
    end

  end
end