module EasyredmineBudgetQuotas
  module TimeEntryValidation

    extend ActiveSupport::Concern

    included do
      before_save :check_if_budget_quota_valid, if: :applies_on_budget_or_quota?
      before_save :verify_valid_from_to, if: :is_budget_quota?
    end

    def check_if_budget_quota_valid
    end

    def valid_from
      Date.parse(ebq_custom_field_value('ebq_valid_from')) rescue nil
    end

    def valid_to
      Date.parse(ebq_custom_field_value 'ebq_valid_to') rescue nil
    end

    def budget_quota_source
      ebq_custom_field_value 'ebq_budget_quota_source'
    end

    def budget_quota_value
      ebq_custom_field_value('ebq_budget_quota_value').to_f
    end

    def is_budget_quota?
      (EasyredmineBudgetQuotas.budget_entry_activities.ids + EasyredmineBudgetQuotas.budget_entry_activities.ids).include?(self.activity_id)
    end

    private

    def check_if_budget_quota_valid
      # check if choosen source is available
      if budget_quota_source.to_s.match(/budget|quota/) && self.project.send("current_#{budget_quota_source}_entry_valid?")
        already_spent = self.project.query_spent_entries_on(type: budget_quota_source).map(&:price).sum
        will_be_spent = EasyMoneyTimeEntryExpense.compute_expense(self, project.external_rate_id)

        can_be_spent = project.send("current_#{budget_quota_source}_value").to_f

        if can_be_spent < already_spent+will_be_spent
          self.errors.add(:ebq_budget_quota_value, "Limit of #{can_be_spent} for #{budget_quota_source} will be exceeded (#{already_spent+will_be_spent}) - cant add entry")
          return false
        end
      else
        self.errors.add(:ebq_budget_quota_source, "Using #{budget_quota_source} is not available for this project. No valid #{budget_quota_source} entry found.")
        return false
      end

    end

    def applies_on_quota?
      budget_quota_source == 'quota'
    end

    def applies_on_budget?
      budget_quota_source == 'budget'
    end

    def applies_on_budget_or_quota?
      applies_on_quota? || applies_on_budget?
    end


    def ebq_custom_field_value(v)
      self.custom_field_values.select {|f| f.custom_field.internal_name == v }.first.try(:value)
    end

    def verify_valid_from_to
      self.errors.add(:valid_from, 'required') if ebq_custom_field_value('ebq_valid_from').nil?
      self.errors.add(:valid_to, 'required') if ebq_custom_field_value('ebq_valid_to').nil?

      return self.errors.empty?
    end


  end
end