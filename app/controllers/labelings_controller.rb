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

class LabelingsController < ApplicationController

  load_and_authorize_resource :labeling

  def create
    @labeling = Labeling.create(labeling_params)

    respond_to :js
  end

  def destroy
    @labelings = Labeling.find(params[:id])

    @labelings.destroy

    respond_to :js
  end

  protected
    def labeling_params
      params.require(:labeling).permit(
          :label_id,
          :labelable_id,
          :labelable_type,
          label: [
              :name
          ]
      )
    end
end
