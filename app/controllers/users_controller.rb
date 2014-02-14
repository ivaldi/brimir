# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2014-2014 Ivaldi http://ivaldi.nl
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

class UsersController < ApplicationController
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    # if no password was posted, remove from params
    if params[:user][:password] == ''
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update_attributes(user_params)
      redirect_to tickets_url, notice: 'Settings saved'
    else
      render action: 'edit'
    end
  end

  private
    def user_params
      # Setup accessible (or protected) attributes for your model
      params.require(:user).permit(:email, :password, :password_confirmation,
          :remember_me, :signature)
    end

end
