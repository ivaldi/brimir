# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2016 Ivaldi https://ivaldi.nl/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
