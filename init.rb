Redmine::Plugin.register :easyredmine_budget_quotas do
  name 'BudgetQuotas for EasyRedmine'
  author 'Florian Eck for akquinet'
  description 'Keep track of assigned budgets and quotas for spent time/money on projects'
  version '1.12'

  project_module :budget_quotas do
    permission :edit_settings, :budget_quotas => :settings
  end

end

require 'easyredmine_budget_quotas'
require 'easyredmine_budget_quotas/project_budget_quota'
require 'easyredmine_budget_quotas/time_entry_validation'
require 'easyredmine_budget_quotas/hooks'



Rails.application.config.after_initialize do
  Project.send(:include, EasyredmineBudgetQuotas::ProjectBudgetQuota)
  TimeEntry.send(:include, EasyredmineBudgetQuotas::TimeEntryValidation)
end
