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

class Reply < ActiveRecord::Base
  include CreateFromUser

  has_many :attachments, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments

  validates_presence_of :ticket_id, :content

  belongs_to :ticket
  belongs_to :user

  scope :chronologically, -> { order(:id) }
  scope :with_message_id, -> {
    where.not(message_id: nil)
  }

  def to
    to = read_attribute(:to)

    # send to ticket starter when not current user and no to address set
    if to.blank? && self.ticket.user != self.user
      self.ticket.user.email
    else
      to
    end
  end

  def other_replies
    self.ticket.replies.where.not(id: self.id)
  end

  def users_to_notify
    to = [ticket.user.email]

    other_replies.each do |r|
      to << r.user.email
    end

    assignee = ticket.assignee
    if assignee.present?
      to << assignee.email
    else
      to += User.agent_addresses_to_notify
    end

    to.uniq - [user.email]
  end

end
