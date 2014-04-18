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
  end

  def update
    @user = User.find(params[:id])

    # if no password was posted, remove from params
    if params[:user][:password] == ''
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    #prevent normal user from changing email and role
    if !current_user.agent?
      params[:user].delete(:email)
      params[:user].delete(:agent)
    end

    if @user.update_attributes(user_params)

      if current_user.agent?
        redirect_to users_url, notice: 'Settings saved'
      else
        redirect_to tickets_url, notice: 'Settings saved'
      end

    else
      render action: 'edit'
    end
  end

  def index

    if params[:format].nil?
      @users = User.ordered.page(params[:page])
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
  end

  def create

    @user = User.new(user_params)

    if @user.save
      redirect_to users_url, notice: 'User succesfully added.'
    else
      render 'new'
    end

  end

  private
    def user_params
      # Setup accessible (or protected) attributes for your model
      params.require(:user).permit(:email, :password, :password_confirmation,
          :remember_me, :signature, :agent)
    end

end
