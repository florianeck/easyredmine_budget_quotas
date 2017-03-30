module EasyredmineBudgetQuotas
  module TimeEntryValidation

    extend ActiveSupport::Concern
    included do
      before_save :check_if_budget_quota_valid, if: [:applies_on_budget_or_quota?, :project_uses_budget_quota?]
      before_save :verify_valid_from_to, if: [:is_budget_quota?, :project_uses_budget_quota?]
      after_create :set_ebq_budget_quota_id, if: :is_budget_quota?
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
      if budget_quota_source.to_s.match(/budget|quota/)

        current_bq = self.project.get_current_budget_quota_entry(type: budget_quota_source.to_sym, ref_date: self.spent_on)

        if current_bq.nil?
          self.errors.add(:ebq_budget_quota_source, "No #{budget_quota_source} is defined/available for this project at #{self.spent_on}")
          return false
        elsif current_bq.try(:easy_locked?)

          already_spent = self.project.query_spent_entries_on(type: budget_quota_source, ref_date: self.spent_on).map(&:price).sum

          if self.persisted?
            # need to substract existing time entry
            r = EasyMoneyTimeEntryExpense.easy_money_time_entries_by_time_entry_and_rate_type(self, EasyMoneyRateType.find_by(name: project.budget_quotas_money_rate_type)).first
            already_spent -= r.price if r
          end

          will_be_spent = EasyMoneyTimeEntryExpense.compute_expense(self, project.calculation_rate_id)
          can_be_spent  = current_bq.try(:budget_quota_value).to_f

          # using tolerance/EUR set in the project here
          if (can_be_spent + project.budget_quotas_tolerance_amount) < already_spent+will_be_spent
            self.errors.add(:ebq_budget_quota_value, "Limit of #{can_be_spent} for #{budget_quota_source} will be exceeded (#{already_spent+will_be_spent}) - cant add entry")
            return false
          else
            assign_custom_field_value_for_ebq_budget_quota!(id: current_bq.id, value: will_be_spent*-1)
          end
        else
          self.errors.add(:ebq_budget_quota_source, "Found entry for #{budget_quota_source} - but entry is not locked yet")
          return false
        end
      else
        self.errors.add(:ebq_budget_quota_source, "Invalid source name #{budget_quota_source}")
        return false
      end

    end


    def assign_custom_field_value_for_ebq_budget_quota!(id: , value: )
      cf_id     = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_id' }
      cf_value  = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_value' }
      self.custom_field_values = {cf_id.id => id, cf_value.id => value}
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

    def set_self_ebq_budget_quota_id
      return unless :is_budget_quota?
      cf_id     = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_id' }
      self.custom_field_values = {cf_id.id => self.id}
      self.save
    end

    def project_uses_budget_quota?
      self.project.module_enabled?(:budget_quotas)
    end


  end
end