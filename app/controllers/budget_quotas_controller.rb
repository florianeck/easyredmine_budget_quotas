class BudgetQuotasController < ApplicationController

  def update_project_settings
    @project = Project.find(params[:id])
    @project.budget_quotas_money_rate_type = params[:project][:budget_quotas_money_rate_type]
    @project.ebq_rate_type_settings = params[:project][:ebq_rate_type_settings].to_hash
    @project.save

    redirect_to :back
  end
  
  def assign_budget_quota_to_time_entries
    @time_entries = TimeEntry.where(id: params[:time_entry_ids])
    notice = []
    error  = []
    @bq = TimeEntry.find(params[:budget_quota_id])
    
    @time_entries.each do |entry|
      if entry.assign_budget_quota(params[:budget_quota_id])
        notice << "Assigned #{entry.comments} to #{@bq.comments}"
      else
        error << "Failed to assign #{entry.comments} to #{@bq.comments}"
      end
    end
    
    flash[:notice] = notice.join("<br >/") if notice.any?
    flash[:error] = error.join("<br >/") if error.any?
    redirect_to :back
  end
  
  def unassign_budget_quota_to_time_entries
    @time_entries = TimeEntry.where(id: params[:time_entry_ids], easy_locked: false)
    @time_entries.each do |entry|
      entry.unassign_budget_quota
    end
    
    redirect_to :back
  end

end