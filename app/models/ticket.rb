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

class Ticket < ActiveRecord::Base
  include CreateFromUser

  validates_presence_of :user_id

  belongs_to :user
  belongs_to :assignee, class_name: 'User'

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings

  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :notified_users, source: :user, through: :notifications

  has_many :status_changes, dependent: :destroy

  enum status: [:open, :closed, :deleted, :waiting]
  enum priority: [:unknown, :low, :medium, :high]

  after_update :log_status_change
  after_create :create_status_change

  def self.active_labels(status)
    label_ids = where(status: Ticket.statuses[status])
        .joins(:labelings)
        .pluck(:label_id)
        .uniq

    return Label.where(id: label_ids)
  end

  scope :by_label_id, ->(label_id) {
    if label_id.to_i > 0
      joins(:labelings).where(labelings: { label_id: label_id })
    end
  }

  scope :by_status, ->(status) {
    where(status: Ticket.statuses[status.to_sym])
  }

  scope :filter_by_assignee_id, ->(assignee_id) {
    if !assignee_id.nil?
      if assignee_id.to_i == 0
        where(assignee_id: nil)
      else
        where(assignee_id: assignee_id)
      end
    else
      all
    end
  }

  scope :search, ->(term) {
    if !term.nil?
      term = '%' + term.downcase + '%'
      where('LOWER(subject) LIKE ? OR LOWER(content) LIKE ?',
          term, term)
    end
  }

  scope :ordered, -> {
    order(:created_at).reverse_order
  }

  scope :viewable_by, ->(user) {
    if !user.agent?
      ticket_ids = Labeling.where(label_id: user.label_ids)
          .where(labelable_type: 'Ticket')
          .pluck(:labelable_id)
      where('tickets.id IN (?) OR tickets.user_id = ?', ticket_ids, user.id)
    end
  }

  def set_default_notifications!(created_by)

    # customer created ticket for another user
    if !created_by.agent? && created_by != user
      self.notified_user_ids = User.agents_to_notify.pluck(:id)
      self.notified_user_ids << user.id

    # ticket created by customer
    elsif !created_by.agent?
      self.notified_user_ids = User.agents_to_notify.pluck(:id)

    # ticket created by agent for another user
    elsif created_by.agent? && created_by != user
      self.notified_user_ids = [user.id]

    # agent created ticket for himself
    else
      self.notified_user_ids = []
    end
  end

  def status_times
    total = {}

    Ticket.statuses.keys.each do |key|
      total[key.to_sym] = 0
    end

    status_changes.each do |status_change|
      total[status_change.status.to_sym] += status_change.updated_at - status_change.created_at
    end

    # add the current status as well
    current = status_changes.ordered.last
    unless current.nil?
      total[current.status.to_sym] += Time.now - current.created_at
    end

    Ticket.statuses.keys.each do |key|
      total[key.to_sym] /= 1.minute
    end

    total
  end

  protected
    def create_status_change
      status_changes.create! status: self.status
    end

    def log_status_change

      if self.changed.include? 'status'
        previous = status_changes.ordered.last

        unless previous.nil?
          previous.updated_at = Time.now
          previous.save
        end

        status_changes.create! status: self.status
      end
    end

end
