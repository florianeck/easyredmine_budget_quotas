module EasyredmineBudgetQuotas
  class Hooks < Redmine::Hook::ViewListener

    def helper_project_settings_tabs(context={})
      context[:tabs] << {
        :name => 'budget_quotas', :action => :manage_easy_checklist_templates,
        :partial => 'projects/settings/budget_quotas', :label => :project_module_budget_quotas,
        :no_js_link => true
      } if context[:project].module_enabled?(:budget_quotas)
    end

  end
end
