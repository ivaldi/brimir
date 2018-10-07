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

module TimeHelper
  # Wrap the localized term "ago" around the output of +time_ago_in_words+
  #
  # Examples:
  #   I18n.locale = :en
  #   time_ago_as_phrase(Time.now - 5.minutes)
  #   # => "5 minutes ago"
  #   I18n.locale = :fr-FR
  #   time_ago_as_phrase(Time.now - 5.minutes)
  #   # => "il y a 5 minutes"
  def time_ago_as_phrase(*arguments)
    I18n.t(:time_ago_as_phrase, timespan: time_ago_in_words(*arguments))
  end
end
