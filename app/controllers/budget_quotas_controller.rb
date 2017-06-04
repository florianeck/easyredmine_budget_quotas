class BudgetQuotasController < ApplicationController

  def update_project_settings
    @project = Project.find(params[:id])
    @project.budget_quotas_money_rate_type = params[:project][:budget_quotas_money_rate_type]
    @project.budget_quotas_tolerance_amount = params[:project][:budget_quotas_tolerance_amount]
    @project.ebq_rate_type_settings = params[:project][:ebq_rate_type_settings].to_hash
    @project.save

    redirect_to :back
  end

end