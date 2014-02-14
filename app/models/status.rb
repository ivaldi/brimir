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

class Status < ActiveRecord::Base
  validates_presence_of :name

  has_many :tickets

  scope :default, -> { where(default: true) }

  def self.all_status
    Status.new(name: "All", id: 0)
  end

  def self.default_status
    default.first
  end

  def self.find_by_id_from_filters(id)
    return default_status if id.nil?
    return all_status if id.to_i.zero?

    find id
  end

  def self.filters
    [Status.new(name: "All", id: 0)] + all
  end

  def all_status?
    !id.nil? && id.zero?
  end

  def tickets(*args)
    if all_status?
      Ticket.where(args)
    else
      super(*args)
    end
  end

  def as_adjective
    return '' if all_status?

    name.downcase
  end
end
