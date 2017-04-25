module EasyredmineBudgetQuotas
  class Hooks < Redmine::Hook::ViewListener

    render_on :view_custom_fields_form_time_entry_custom_field, :partial => 'custom_fields/akquinet_view_custom_fields_form_time_entry_custom_field'
    render_on :view_time_entries_user_time_entry_middle, :partial => 'timelog/akquinet_view_time_entries_user_time_entry_middle'

    def view_enumerations_form_bottom(context={})
      enumeration = context[:enumeration]

      if enumeration.is_a?(TimeEntryActivity)
        context[:controller].send(:render_to_string, :partial => 'enumerations/akquinet_view_enumerations_form_bottom', :locals => context)
      end
    end


    def helper_project_settings_tabs(context={})
      context[:tabs] << {
        :name => 'budget_quotas', :action => :manage_easy_checklist_templates,
        :partial => 'projects/settings/budget_quotas', :label => :project_module_budget_quotas,
        :no_js_link => true
      } if context[:project].module_enabled?(:budget_quotas)
    end


  end
end
