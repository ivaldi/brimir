class RulesController < ApplicationController

  load_and_authorize_resource :rule

  def index
    @rules = @rules.paginate(page: params[:page])
  end

  def new
  end

  def create
    @rule = Rule.new(rule_params)

    if @rule.save
      redirect_to rules_url, notice: t(:rule_added)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @rule.update_attributes(rule_params)
      redirect_to rules_url, notice: t(:rule_modified)
    else
      render 'edit'
    end
  end

  def destroy
    @rule.destroy

    redirect_to rules_url, notice: t(:rule_deleted)
  end

  protected
    def rule_params
      params.require(:rule).permit(
          :filter_field,
          :filter_operation,
          :filter_value,
          :action_operation,
          :action_value,
      )
    end

end
