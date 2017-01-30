Redmine::Plugin.register :easyredmine_budget_quotas do
  name 'BudgetQuotas for EasyRedmine'
  author 'Florian Eck for akquinet'
  description 'Keep track of assigned budgets and quotas for spent time/money on projects'
  version '1.0'
end

require 'easyredmine_budget_quotas'
require 'easyredmine_budget_quotas/project_budget_quota'
require 'easyredmine_budget_quotas/time_entry_validation'

Rails.application.config.after_initialize do
  Project.send(:include, EasyredmineBudgetQuotas::ProjectBudgetQuota)
  TimeEntry.send(:include, EasyredmineBudgetQuotas::TimeEntryValidation)
end
