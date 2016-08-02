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

class UsersController < ApplicationController
  include UsersStrongParams
  load_and_authorize_resource :user

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

    if current_user == @user
      params[:user].delete(:agent) # prevent removing own agent permissions
    end

    if @user.update_attributes(user_params)

      if current_user.agent? && current_user.labelings.count == 0
        redirect_to users_url, notice: I18n.translate(:settings_saved)
      else
        redirect_to tickets_url, notice: I18n.translate(:settings_saved)
      end

    else
      render action: 'edit'
    end
  end

  def index
    @users = User.ordered.paginate(page: params[:page])
    @users = @users.search(params[:q])
    @users = @users.by_agent(params[:agent] == '1') unless params[:agent].blank?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_url, notice: I18n.translate(:user_added)
    else
      render 'new'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, notice: I18n.translate(:user_removed)
  end
end
