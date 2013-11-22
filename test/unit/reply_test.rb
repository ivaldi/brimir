# Brimir is a helpdesk system that can be used to handle email support requests.
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

require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  setup do
    @reply = replies(:solution)
  end

  test "should deliver the mail when notifying" do
    test_mailer = OpenStruct.new.tap do |x|
      def x.deliver
        @deliveries ||= 0
        @deliveries += 1
      end

      def x.deliveries
        @deliveries
      end
    end

    @reply.notify { |reply| test_mailer }

    assert_equal 1, test_mailer.deliveries
  end
end
