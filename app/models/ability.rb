# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012 Ivaldi https://ivaldi.nl/
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

# define permissions for all types of users
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :create, Ticket
    can :create, Attachment

    if user.agent?
      agent user
    else
      customer user
    end
  end

  protected

  def customer(user)
    # customers can view their own tickets, its replies and attachments
    can [:new, :create, :read], Reply, ticket: { user_id: user.id }

    # customers can edit their own account
    can [:edit, :update], User, id: user.id

    # customer can see al tickets labeled with his/her labels
    can :read, Ticket, Ticket.viewable_by(user) do |ticket|
      # at least one label_id overlap
      ticket.user == user || (ticket.label_ids & user.label_ids).size > 0
    end

    can [:new, :create, :read], Reply do |reply|
      # at least one label_id overlap
      (reply.ticket.label_ids & user.label_ids).size > 0
    end
  end

  def agent(user)
    # agents can reply to tickets that are locked by themselves or unlocked
    can [:new, :create, :read], Reply, Reply.unlocked_for(user) do |reply|
      !reply.ticket.locked?(user)
    end

    # agents can edit all users
    can :manage, User

    can [:read], Ticket
    # agents can manage all tickets that are locked by themselves or unlocked
    can [:update, :destroy], Ticket, Ticket.unlocked_for(user) do |ticket|
      !ticket.locked?(user)
    end

    # agent can create/destroy labelings for tickets locked by themselves or
    # unlocked
    can [:create, :destroy], Labeling, labelable_type: 'Ticket',
        labelable: { locked_by_id: [user.id, nil] }

    can [:create, :destroy], Labeling, labelable_type: 'User'
    can :manage, Rule
    can :manage, EmailAddress
    can :manage, Label
  end
end
