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
    
    def view_time_entries_context_menu_end(context = {})
      
      has_only_assignable_entries = context[:time_entries].detect do |e| 
        !e.project_uses_budget_quota? || e.is_budget_quota?
      end.nil?

      output = []
      
      if has_only_assignable_entries
        assignable_to = EasyredmineBudgetQuotas.get_available_budget_quotas_for_time_entry_ids(context[:time_entries].map(&:id))
        
        if assignable_to.any?
          output << content_tag(:li, context[:hook_caller].render("timelog/assign_budget_quota_menu_entry", assignable_to: assignable_to, time_entry_ids: context[:time_entries].map(&:id)), class: "folder")
        end    
      end  
      
      return output.join
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
