# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012 Ivaldi http://ivaldi.nl
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

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.agent?
      can :manage, :all
    else

      # customers can view their own tickets, its replies and attachments
      can [:read, :create, :new], Ticket, user_id: user.id
      can [:new, :create, :read], Reply, ticket: { user_id: user.id }
      can [:create], Reply, ticket: nil # preview reply
      can :read, Attachment, attachable_type: 'Ticket', attachable: { user_id: user.id }
      can :read, Attachment, attachable_type: 'Reply', attachable: { ticket: { user_id: user.id } }

      # customers can edit their own account
      can [:edit, :update], User, id: user.id
    end
  end
end
