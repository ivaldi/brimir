# Brimir is a helpdesk system that can be used to handle email support requests.
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

require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  teardown do
    Time.zone = 'Etc/UTC'
  end

  test 'should parse and write start' do
    # stub a schedule
    schedule = schedules(:empty)

    assert_nil schedule.start 

    schedule.start = '08:00'

    schedule.save!
    schedule.reload

    Time.zone = 'Amsterdam'

    assert_match 'Amsterdam', Time.zone.name

    assert_equal schedule.start, Time.zone.parse('08:00')
    assert_equal schedule.start.hour, 8

  end

  test 'should parse and write end' do

    # stub a schedule
    schedule = schedules(:empty)

    assert_nil schedule.end

    schedule.end = '08:00'

    schedule.save!
    schedule.reload

    Time.zone = 'Amsterdam'

    assert_match 'Amsterdam', Time.zone.name

    assert_equal schedule.end, Time.zone.parse('08:00')
    assert_equal schedule.end.hour, 8
  end

end
