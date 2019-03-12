module EasyredmineBudgetQuotas
  module TimeEntryValidation

    extend ActiveSupport::Concern
    included do
      before_save :check_if_budget_quota_valid, if: [:applies_on_budget_or_quota?, :project_uses_budget_quota?]
      before_save :verify_valid_from_to, if: [:is_budget_quota?, :project_uses_budget_quota?]
      before_save :set_self_ebq_budget_quota_id
      before_save :set_exceeded_flag
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
      is_budget? || is_quota?
    end

    def is_budget?
      EasyredmineBudgetQuotas.send("budget_entry_activities").ids.include?(self.activity_id)
    end

    def is_quota?
      EasyredmineBudgetQuotas.send("quota_entry_activities").ids.include?(self.activity_id)
    end

    def required_min_budget_value
      if self.non_hour_based?
        0
      else
        if @_required_min_budget_value.nil?
          fake_entry = self.class.new(activity_id: self.activity_id, hours: 0.01, project_id: self.project_id)
          fake_entry.user_id = self.user_id
          @_required_min_budget_value = EasyMoneyTimeEntryExpense.compute_expense(fake_entry, project.calculation_rate_id)
        end
        return @_required_min_budget_value
      end
    end

    # checking for an not-hour-based time entry
    # (those must not be splitted)
    def non_hour_based?
      self.hours.zero? && !will_be_spent.zero?
    end

    # how much will this item cost?
    def will_be_spent
      EasyMoneyTimeEntryExpense.compute_expense(self, project.calculation_rate_id)
    end

    def remaining_value
      if is_budget_quota?
        self.budget_quota_value.to_f - self.project.query_spent_entries_on(self).sum(&:price)
      else
        0
      end
    end

    def remaining_value_with_tolerance
      self.remaining_value + self.budget_quotas_tolerance_amount.to_f
    end

    def time_entries_in_budget_quota_group
      @_time_entries_in_budget_quota_group ||= if budget_quota_id
        TimeEntry.where(id: CustomValue.find_by_sql("SELECT customized_id from custom_values where customized_type ='TimeEntry' and custom_field_id = '#{budget_quota_field_id}' and value = #{budget_quota_id}").map(&:customized_id))
      else
        []
      end
    end

    def budget_quota_field_id
      @_bq_quota_field_id ||= self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_id' }.try(:id)
    end

    def budget_quotas_tolerance_amount_id
      @_bq_tolerance_amount_id ||= self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_tolerance' }.try(:id)
    end

    def budget_quota_id
      @_budget_quota_id ||= self.custom_field_value(budget_quota_field_id.to_i)
    end

    def budget_quotas_tolerance_amount
      @_budget_quotas_tolerance_amount ||= self.custom_field_value(budget_quotas_tolerance_amount_id.to_i).to_i
    end

    def current_budget_quota_entry
      @_current_budget_quota_entry ||= TimeEntry.find_by(id: budget_quota_id)
    end

    def group_time_entries_all_locked?
      if time_entries_in_budget_quota_group.size > 1
        time_entries_in_budget_quota_group.where(easy_locked: false).where.not(id: self.id).empty?
      else
        return false
      end
    end

    def project_uses_budget_quota?
      self.project.module_enabled?(:budget_quotas)
    end

    def assign_budget_quota(bq_id)
      entry = TimeEntry.find(bq_id)

      cf_id      = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_id' }
      cf_source  = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_source' }

      self.custom_field_values = {cf_id.id => bq_id, cf_source.id => (entry.is_budget? ? 'budget' : 'quota')}
      self.save
    end

    def unassign_budget_quota
      cf_id      = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_id' }
      cf_source  = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_source' }
      cf_value   = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_value' }

      self.custom_field_values = {cf_id.id => nil, cf_source.id => nil, cf_value.id => 0 }
      self.save
    end

    def current_bq
      TimeEntry.find_by(id: budget_quota_id)
    end

    def current_bqs
      TimeEntry.where(id: budget_quota_id)
    end

    def comment_link
      "<a href=\"/bulk_time_entries?time_entry_id=#{self.id}\">#{self.comments.presence || self.id}</a>".html_safe
    end

    def to_s
      "#{self.comments.presence || self.id} - #{self.project.name}"
    end

    private

    def set_exceeded_flag
      if current_bq && current_bq.remaining_value <= current_bq.budget_quotas_tolerance_amount && self.easy_locked? && group_time_entries_all_locked?
        TimeEntry.find_by(id: budget_quota_id).try(:update_columns, budget_quota_exceeded: true)
      else
        TimeEntry.find_by(id: budget_quota_id).try(:update_columns, budget_quota_exceeded: false)
      end
    end

    def check_if_budget_quota_valid

      return if self.easy_locked? || self.current_bq.nil?

      # check if choosen source is available
      if budget_quota_source.to_s.match(/budget|quota/)

        if current_bqs.empty?
          self.errors.add(:ebq_budget_quota_source, "No #{budget_quota_source} is defined/available for this project at #{self.spent_on}")
          return false
        else
          # check if  BudgetQuota covers expense
          already_spent_on_entries = current_bqs.map {|bq| self.project.query_spent_entries_on(bq).map(&:price).sum }
          can_be_spent_on_entries  = current_bqs.map {|bq| bq.try(:budget_quota_value).to_f + bq.budget_quotas_tolerance_amount }

          already_spent = already_spent_on_entries.sum

          already_spent_on_self = 0

          if self.persisted?
            # need to substract existing time entry
            already_spent_on_self = EasyMoneyTimeEntryExpense.easy_money_time_entries_by_time_entry_and_rate_type(self, EasyMoneyRateType.find_by(name: project.budget_quotas_money_rate_type)).first.try(:price).to_f
            already_spent -= already_spent_on_self
          end

          # non hour based entries cant be splitted
          if non_hour_based?
            matching_bq = current_bqs.detect {|bq| (bq.remaining_value + already_spent_on_self) >= will_be_spent }

            if matching_bq.present?
              assign_custom_field_value_for_ebq_budget_quota!(id: matching_bq.id, value: -1*will_be_spent)
              return true # => important! stop here, otherwise, value gets assigned to wrong BQ
            else
              self.errors.add(:ebq_budget_quota_value, "No matching Budget/Quota found to assign non-splittable value of #{will_be_spent}")
              return false
            end
          else# (can_be_spent_on_entries.first + current_bq.budget_quotas_tolerance_amount) < already_spent_on_entries.first+(will_be_spent-already_spent_on_self)

            # Checking the actual amount of assigable hours
            assignable_value = will_be_spent.to_f - ((already_spent_on_entries.first+will_be_spent).to_f - can_be_spent_on_entries.first)
            value_per_hour   = will_be_spent/self.hours

            assignable_hours = assignable_value/value_per_hour

            if assignable_hours < self.hours
              # Split non-assignable hours value and store in other time entry
              create_next_time_entry(self.attributes.merge('hours' => self.hours - assignable_hours, 'comments' => "#{self.comments} (splitted #{(self.hours - assignable_hours).round(2)}h)"))

              # Assign currently applicable value
              self.hours = assignable_hours
            end
          end

          assign_custom_field_value_for_ebq_budget_quota!(id: current_bqs.first.id, value: (-1*will_be_spent).round(2))
        end
      else
        self.errors.add(:ebq_budget_quota_source, "Invalid source name #{budget_quota_source}")
        return false
      end
    end


    def create_next_time_entry(values = {})
      next_entry = self.class.new(values.except('id','user_id', 'tyear', 'tmonth', 'tweek'))

      # next line because of: WARNING: Can't mass-assign protected attributes for TimeEntry: user_id
      next_entry.user_id = self.user_id
      next_entry.save
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
      if self.errors.empty?
        if self.comments.blank?
          self.comments = "#{budget_quota_source} / #{self.budget_quota_value} (#{ebq_custom_field_value('ebq_valid_from')} - #{ebq_custom_field_value('ebq_valid_to')}"
        end

        return true
      else
        return false
      end
    end

    # Auto-assign the source of budget-quota to self.id if current entry is a budget/quota source.
    # this is required to get correct summed up values when grouping by 'source of budget quota'
    def set_self_ebq_budget_quota_id
      unless is_budget_quota?
        return
      else
        cf_id = self.available_custom_fields.detect {|cf| cf.internal_name == 'ebq_budget_quota_id' }
        self.custom_field_values = {cf_id.id => self.id}
      end
    end


  end
end