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
    can :update, Reply, user_id: user.id
    can :update, Reply, user_id: nil

    if user.agent?
      if user.labelings.count > 0
        limited_agent user
      else
        agent user
      end
    else
      customer user
    end
  end

  protected

  def customer(user)
    # customers can view replies where they were notified of
    can :read, Reply do |reply|
      reply.notified_user_ids.include? user.id || reply.user_id == user.id
    end
    # customers can view their own replies
    can :read, Reply, user_id: user.id
    # customers can reply to their own tickets
    can :create, Reply, ticket: { user_id: user.id }

    # customers can reply when they have access to the label
    can :create, Reply do |reply|
      # at least one label_id overlap or ticket of user himself
      (reply.ticket.label_ids & user.label_ids).size > 0
    end

    # customers can edit their own account
    can :update, User, id: user.id

    # customer can see al tickets labeled with his/her labels
    can :read, Ticket, Ticket.viewable_by(user) do |ticket|
      # at least one label_id overlap
      ticket.user == user || (ticket.label_ids & user.label_ids).size > 0
    end
  end

  def limited_agent(user)
    # limited agents can view their own tickets, replies and attachments
    can [:create, :read], Reply, ticket: { user_id: user.id }

    # limited agents can edit their own account
    can :update, User, id: user.id

    # limited agents can see al tickets labeled with his/her labels
    can [:read, :update], Ticket, Ticket.viewable_by(user) do |ticket|
      # at least one label_id overlap or assigned to
      ticket.user == user || (ticket.label_ids & user.label_ids).size > 0 ||
          ticket.assignee == user
    end

    can [:create, :read], Reply do |reply|
      # at least one label_id overlap
      (reply.ticket.label_ids & user.label_ids).size > 0
    end
  end

  def agent(user)
    # agents can reply to tickets that are locked by themselves or unlocked
    can [:create, :read], Reply, Reply.unlocked_for(user) do |reply|
      !reply.ticket.locked?(user)
    end

    # agents can edit all users
    can [:read, :create, :update], User
    can :destroy, User do |u|
      u.tickets.count == 0 &&
          u.replies.count == 0 &&
          u.id != user.id
    end

    can [:read], Ticket
    # agents can manage all tickets that are locked by themselves or unlocked
    can [:update, :destroy], Ticket, Ticket.unlocked_for(user) do |ticket|
      !ticket.locked?(user)
    end

    # agent can create/destroy labelings for tickets locked by themselves or
    # unlocked
    can [:create, :destroy], Labeling, labelable_type: 'Ticket',
        labelable: { locked_by_id: [user.id, nil] }

    can [:create, :destroy], Labeling, -> { where(labelable_type: 'User')
        .where.not(labelable_id: user.id) } do |labeling|
      labeling.labelable != user
    end
    can :manage, Rule
    can :manage, EmailAddress
    can :manage, Label

    can :update, Tenant, id: Tenant.current_tenant.id
  end
end
