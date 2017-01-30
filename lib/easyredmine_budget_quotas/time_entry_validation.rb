module EasyredmineBudgetQuotas
  module TimeEntryValidation

    extend ActiveSupport::Concern

    included do
      before_save :check_if_budget_quota_valid if: :applies_on_budget_or_quota?
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

    def applies_on_quota?
      budget_quota_source == 'budget'
    end

    def applies_on_budget?
      budget_quota_source == 'quota'
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