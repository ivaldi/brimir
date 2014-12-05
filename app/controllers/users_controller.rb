# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2014 Ivaldi http://ivaldi.nl
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

  load_and_authorize_resource :user

  def edit
    @user = User.find(params[:id])
    @time_zones = ActiveSupport::TimeZone.all.map(&:name).sort
  end

  def update
    @user = User.find(params[:id])
    @time_zones = ActiveSupport::TimeZone.all.map(&:name).sort

    # if no password was posted, remove from params
    if params[:user][:password] == ''
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if current_user.agent?
      params[:user].delete(:agent) # prevent removing own agent permissions
    end

    if @user.update_attributes(user_params)

      if current_user.agent?
        redirect_to users_url, notice: I18n::translate(:settings_saved)
      else
        redirect_to tickets_url, notice: I18n::translate(:settings_saved)
      end

    else
      render action: 'edit'
    end
  end

  def index

    if params[:format].nil?
      @users = User.ordered.paginate(page: params[:page])
    elsif params[:format] == 'json'
      if params[:init].present?
        @users = params[:q].split(',')
        @users = @users.map { |user| { id: user, text: user } }
      else
        @users = User.by_email(params[:q])
        @users = @users.map { |user| { id: user.email, text: user.email } }
      end

      render json: { users: @users }
    end

  end

  def new
    @user = User.new
    @time_zones = ActiveSupport::TimeZone.all.map(&:name).sort
  end

  def create
    @user = User.new(user_params)
    @time_zones = ActiveSupport::TimeZone.all.map(&:name).sort

    if @user.save
      redirect_to users_url, notice: I18n::translate(:user_added)
    else
      render 'new'
    end

  end

  private
    def user_params
      attributes = params.require(:user).permit(
          :email,
          :password,
          :password_confirmation,
          :remember_me,
          :signature,
          :agent,
          :notify,
          :time_zone,
          :per_page,
          label_ids: []
      )

      # prevent normal user from changing email and role
      unless current_user.agent?
        attributes.delete(:email)
        attributes.delete(:agent)
        attributes.delete(:label_ids)
      end

      return attributes
    end

end
