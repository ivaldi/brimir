# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi https://ivaldi.nl/
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

# replies to tickets, made by a user, possibly with attachments
class Reply < ActiveRecord::Base
  include CreateFromUser

  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :notified_users, source: :user, through: :notifications

  accepts_nested_attributes_for :attachments

  validates :ticket_id, :content, presence: true

  belongs_to :ticket, touch: true
  belongs_to :user

  accepts_nested_attributes_for :ticket

  scope :chronologically, -> { order(:id) }
  scope :with_message_id, lambda {
    where.not(message_id: nil)
  }

  scope :unlocked_for, ->(user) {
    joins(:ticket)
        .where('locked_by_id IN (?) OR locked_at < ?',
            [user.id, nil], Time.zone.now - 5.minutes)
  }

  def set_default_notifications!
    users = users_to_notify.select do |user|
      Ability.new(user).can? :show, self
    end
    self.notified_user_ids = users.map(&:id)
  end

  def other_replies
    ticket.replies.where.not(id: id)
  end

  def users_to_notify
    to = [ticket.user] + other_replies.map(&:user)

    if ticket.assignee.present?
      to << ticket.assignee
    else
      to += User.agents_to_notify
    end

    ticket.labels.each do |label|
      to += label.users
    end

    to.uniq - [user]
  end
end
