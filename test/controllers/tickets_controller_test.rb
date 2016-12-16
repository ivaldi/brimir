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

require 'test_helper'

class TicketsControllerTest < ActionController::TestCase

  setup do
    @ticket = tickets(:problem)
    # read_fixture doesn't work in ActionController::TestCase, so use File.new
    @simple_email = File.new('test/fixtures/ticket_mailer/simple').read
  end

  teardown do
    Timecop.return
    I18n.locale = :en
  end

  test 'should get new as customer' do

    sign_in users(:bob) # customer sign in

    get :new
    assert_response :success
  end

  test 'should get new as agent' do
    sign_in users(:alice)

    get :new
    assert_response :success
  end

  test 'should get new as anonymous' do
    get :new
    assert_response :success
  end

  test 'should create ticket when posted from MTA' do

    # should ignore this in emails, but use application default
    I18n.locale = :nl

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do

        post :create, message: @simple_email, format: :json

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count

  end

  # BEGIN OF TESTS FOR TICKET CREATION
  # SITUATIONS:
  # 1) CAPTCHA / NO CAPTCHA
  # STATES TO TEST:
  # 1) SIGNED IN / NOT SIGNED IN
  # 2) ERROR IN FORM / NO ERROR IN FORM
  # TESTS: SITUATIONS * (2^STATES)
  # ========================================================

  # FIRST
  test 'should create ticket when signed in and captcha' do
    sign_in users(:alice)

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count', 1 do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end

      refute_equal 0, assigns(:ticket).notified_users.count
    end
  end

  # SECOND
  test 'should not create ticket when ivalid and captcha and signed in' do
    sign_in users(:alice)

    assert_no_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_no_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'invalid',
          content: '',
          subject: '',
        }

        assert_response :success
      end
    end

    assert_equal 0, assigns(:ticket).notified_users.count
  end

  # THIRD
  test 'should create ticket when not signed in and captcha' do

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_response :success
      end
    end

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  # FOURTH
  test 'should not create ticket when not signed in and invalid and captcha' do

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      assert_no_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'invalid',
          content: '',
          subject: '',
        }

        assert_response :success
      end
    end

    assert_equal 0, assigns(:ticket).notified_users.count
  end

  # FIFTH
  test 'should create ticket when signed in and no captcha' do
    # we need these after the test
    secret_key = Recaptcha.configuration.secret_key
    site_key  = Recaptcha.configuration.site_key

    # set blank for this test
    Recaptcha.configuration.secret_key = ''
    Recaptcha.configuration.site_key = ''
    sign_in users(:alice)

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count', 1 do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end

      # set the configration back to default
      Recaptcha.configuration.secret_key = secret_key
      Recaptcha.configuration.site_key = site_key

      refute_equal 0, assigns(:ticket).notified_users.count
    end
  end

  # SIXTH
  test 'should not create ticket when signed in and invalid and no captcha' do
    # we need these after the test
    secret_key = Recaptcha.configuration.secret_key
    site_key  = Recaptcha.configuration.site_key

    # set blank for this test
    Recaptcha.configuration.secret_key = ''
    Recaptcha.configuration.site_key = ''

    sign_in users(:alice)
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      assert_no_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'invalid',
          content: '',
          subject: '',
        }

        assert_response :success
      end
    end

    # set the configration back to default
    Recaptcha.configuration.secret_key = secret_key
    Recaptcha.configuration.site_key = site_key

    assert_equal 0, assigns(:ticket).notified_users.count
  end

  # SEVENTH
  test 'should create ticket when not signed in and no captcha' do
    # we need these after the test
    secret_key = Recaptcha.configuration.secret_key
    site_key  = Recaptcha.configuration.site_key

    # set blank for this test
    Recaptcha.configuration.secret_key = ''
    Recaptcha.configuration.site_key = ''

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count', 1 do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_response :success
      end


      # set the configration back to default
      Recaptcha.configuration.secret_key = secret_key
      Recaptcha.configuration.site_key = site_key

      refute_equal 0, assigns(:ticket).notified_users.count
    end
  end

  # EIGHT
  test 'should not create ticket when not signed in and no captcha' do
    # we need these after the test
    secret_key = Recaptcha.configuration.secret_key
    site_key  = Recaptcha.configuration.site_key

    # set blank for this test
    Recaptcha.configuration.secret_key = ''
    Recaptcha.configuration.site_key = ''

    assert_no_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_no_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'invalid',
          content: '',
          subject: '',
        }

        assert_response :success
      end
    end

    # set the configration back to default
    Recaptcha.configuration.secret_key = secret_key
    Recaptcha.configuration.site_key = site_key
    assert_equal 0, assigns(:ticket).notified_users.count
  end

  # END OF TESTS FOR TICKET CREATION
  # ========================================================

  # BEGIN OF TESTS FOR NOTIFICATION SETTINGS FOR USER (SCHEDULE)
  # SITUATIONS:
  # 1) SCHEDULE ENABLED / SCHEDULE DISABLED / SCHEDULE NIL
  # STATES TO TEST:
  # 1) TIME WITHIN RANGE WORKING HOURS / TIME NOT WITHIN RANGE WORKING HOURS
  # 2) DAY WITHIN RANGE WORKING DAYS / DAY WITH RANGE WORKING DAYS
  #
  # WAYS TO CREATE TICKETS
  # 1) MTA
  # 2) NEW TICKET LOGGED IN
  # 3) NEW TICKET NOT LOGGED IN
  #
  # TESTS: WAYS TO CREATE TICKETS * ( SITUATIONS( == 1 ) * (1^N + 2) ) (WHERE CONSTANT 2 IS SCHEDULE NIL AND SCHEDULE DISABLED)
  # ========================================================

  # SCHEDULE ENABLED FOR MTA

  # SCHEDULE NIL
  test 'should notify agent when schedule is nil and ticket is created from MTA' do
    agent = users(:alice)

    assert_nil agent.schedule

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, message: @simple_email, format: :json

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  # SCHEDULE DISABLED
  test 'should notify agent with schedule disabled when ticket is created from MTA' do
    agent = users(:charlie)

    assert_not_nil agent.schedule
    assert_not agent.schedule_enabled

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, message: @simple_email, format: :json

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should notify agent with schedule enabled and day within work day range when ticked created from MTA' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 00:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, message: @simple_email, format: :json

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should notify agent with schedule enabled and time within range working hours when ticked created from MTA' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 23:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, message: @simple_email, format: :json

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should not notify agent with schedule enabled and day not within working days range when ticked created from MTA' do
    agent = users(:charlie)


    agent.schedule = schedules(:parttimer) # charlie is now a parttimer
    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    assert agent.schedule_enabled
    assert_not_nil agent.schedule
    assert agent.schedule.monday?
    assert agent.schedule.tuesday?
    assert agent.schedule.wednesday?
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-03 00:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now
      assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count-1 do
        assert_difference 'Ticket.count' do
          post :create, message: @simple_email, format: :json

          assert_response :success
        end
      end

      refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should not notify agent with schedule enabled and time not within range working hours when ticked created from MTA' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '22:00'

    agent.save!
    agent.reload

    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('22:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 23:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count-1 do
      assert_difference 'Ticket.count' do
        post :create, message: @simple_email, format: :json

        assert_response :success
      end
    end

    refute_equal 0, assigns(:ticket).notified_users.count
  end
  # END SCHEDULE ENABLED FOR MTA

  # SCHEDULE ENABLED FOR NEW TICKET

  # SCHEDULE NIL
  test 'should notify agent when schedule is nil when ticket is created' do
    agent = users(:alice)

    assert_nil agent.schedule

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  # SCHEDULE DISABLED
  test 'should notify agent with schedule disabled when ticket is created' do
    agent = users(:charlie)

    assert_not_nil agent.schedule
    assert_not agent.schedule_enabled

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end


  test 'should notify agent with schedule enabled and day within work day range when ticked created' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 00:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should notify agent with schedule enabled and time within range working hours when ticked created' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 23:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should not notify agent with schedule enabled and day not within working days range when ticked created' do
    agent = users(:charlie)

    agent.schedule = schedules(:parttimer) # charlie is now a parttimer
    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    assert agent.schedule_enabled
    assert_not_nil agent.schedule
    assert agent.schedule.monday?
    assert agent.schedule.tuesday?
    assert agent.schedule.wednesday?
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-03 00:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

      assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count-1 do
        assert_difference 'Ticket.count' do
          post :create, ticket: {
            from: 'test@test.nl',
            content: @ticket.content,
            subject: @ticket.subject,
          }

          assert_response :success
        end
      end

      refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should not notify agent with schedule enabled and time not within range working hours when ticked created' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '22:00'

    agent.save!
    agent.reload

    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('22:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 23:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count-1 do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_response :success
      end
    end

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  # END SCHEDULE ENABLED FOR NEW TICKET

  # SCHEDULE ENABLED FOR NEW TICKET WITH SIGNED IN AGENT

  # SCHEDULE NIL
  test 'should notify agent when schedule is nil when ticket is created with logged in agent' do
    agent = users(:alice)
    sign_in agent

    assert_nil agent.schedule

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  # SCHEDULE DISABLED
  test 'should notify agent with schedule disabled when ticket is created with logged in agent' do
    agent = users(:charlie)
    sign_in agent

    assert_not_nil agent.schedule
    assert_not agent.schedule_enabled

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end


  test 'should notify agent with schedule enabled and day within work day range when ticked created with logged in agent' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    sign_in agent
    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 00:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should notify agent with schedule enabled and time within range working hours when ticked created with logged in agent' do
    agent = users(:charlie)

    # we need to stub the start and end 
    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    sign_in agent
    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 00:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should not notify agent with schedule enabled and day not within working days range when ticked created with logged in agent' do
    agent = users(:charlie)

    agent.schedule = schedules(:parttimer) # charlie is now a parttimer
    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '23:00'

    agent.save!
    agent.reload

    sign_in agent
    assert agent.schedule_enabled
    assert_not_nil agent.schedule
    assert agent.schedule.monday?
    assert agent.schedule.tuesday?
    assert agent.schedule.wednesday?
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('23:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-03 00:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now
      assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count-1 do
        assert_difference 'Ticket.count' do
          post :create, ticket: {
            from: 'test@test.nl',
            content: @ticket.content,
            subject: @ticket.subject,
          }

        assert_redirected_to ticket_url(assigns(:ticket))
        end
      end

      refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should not notify agent with schedule enabled and time not within range working hours when ticked created with logged in agent' do
    agent = users(:charlie)

    agent.schedule_enabled = true
    agent.schedule.start = '00:00'
    agent.schedule.end = '22:00'

    agent.save!
    agent.reload

    sign_in agent
    assert_not_nil agent.schedule
    assert agent.schedule_enabled
    assert_equal agent.schedule.start, Time.find_zone('UTC').parse('00:00')
    assert_equal agent.schedule.end, Time.find_zone('UTC').parse('22:00')

    new_time = Time.find_zone(agent.time_zone).parse('2016-12-02 23:00')
    Timecop.freeze(new_time)

    assert_equal new_time, Time.now

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count-1 do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end
    end

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  # END SCHEDULE ENABLED FOR NEW TICKET WITH SIGNED IN AGENT

  # END OF TESTS FOR NOTIFICATION SETTINGS FOR USER (SCHEDULE)
  # ========================================================

  test 'should only allow agents to view others tickets' do
    sign_in users(:bob)

    get :show, id: tickets(:multiple)
    assert_response :unauthorized # redirect to sign in page
  end

  test 'should get index' do
    sign_in users(:alice)

    get :index
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test 'should get csv index' do
    sign_in users(:alice)

    get :index, format: :csv
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test 'should show ticket' do
    sign_in users(:alice)

    get :show, id: @ticket.id
    assert_response :success

    # should contain this for label adding with javascript
    assert_select '[data-labelings]'

    # should contain this for label removing with javascript
    assert_select "[data-labeling-id='#{@ticket.labelings.first.id}']"

    # should contain this anchor for linking from notification email
    assert_select "[id=reply-#{@ticket.replies.first.id}]"

    # should have this icon for label color update javascript (sidebar)
    assert_select 'aside ul li span'

    # should have selected same outgoing address as original received
    assert_select 'option[selected="selected"]' +
      "[value=\"#{email_addresses(:brimir).id}\"]"

    # should contain this for internal note switch
    assert_select '[data-notified-users]'
  end

  test 'should email assignee if ticket is assigned by somebody else' do
    sign_in users(:alice)

    # new assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { assignee_id: users(:charlie).id }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word assigned is in the body
    # in the future we might use templates or translations...
    assert_match 'assigned', ActionMailer::Base.deliveries.last.body.decoded
  end

  test 'should email assignee if status of ticket is changed by somebody else' do
    sign_in users(:charlie)

    # assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { status: 'closed' }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word status is in the body
    # in the future we might use templates or translations...
    assert_match 'status', ActionMailer::Base.deliveries.last.body.decoded
  end

  test 'should email assignee if priority of ticket is changed by somebody else' do
    sign_in users(:charlie)

    # assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { priority: 'high' }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word priority is in the body
    # in the future we might use templates or translations...
    assert_match 'priority', ActionMailer::Base.deliveries.last.body.decoded

  end

  test 'should not email assignee if ticket is assigned by himself' do
    sign_in users(:charlie)

    # new assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { assignee_id: users(:charlie).id }
      assert_redirected_to ticket_path(@ticket)

    end

  end

  test 'should not email assignee if status of ticket is changed by himself' do
    sign_in users(:alice)

    # assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { status: 'closed' }
      assert_redirected_to ticket_path(@ticket)

    end

  end

  test 'should not email assignee if priority of ticket is changed by himself' do
    sign_in users(:alice)

    # assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { priority: 'high' }
      assert_redirected_to ticket_path(@ticket)

    end

  end

  test 'should not show duplicate tickets to agents' do
    sign_in users(:alice)

    @ticket.labels.create!(name: 'test1')
    @ticket.labels.create!(name: 'test2')

    get :index
    assert_response :success

    tickets = assigns(:tickets)
    assert_equal tickets.pluck(:id).uniq, tickets.pluck(:id)

  end

  test 'should not show duplicate tickets to customers' do
    charlie = users(:charlie)
    sign_in charlie

    label = @ticket.labels.create!(name: 'test1')
    charlie.labels << label

    label = @ticket.labels.create!(name: 'test2')
    charlie.labels << label

    get :index
    assert_response :success

    tickets = assigns(:tickets)
    assert_equal tickets.pluck(:id).uniq, tickets.pluck(:id)

  end

  test 'should not notify when a bounce message is received' do
    email = File.new('test/fixtures/ticket_mailer/bounce').read

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      assert_difference 'Ticket.count' do

        post :create, message: email, format: :json

        assert_response :success

      end
    end
  end

  test 'should not save invalid' do
    email = File.new('test/fixtures/ticket_mailer/invalid').read

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      assert_no_difference 'Ticket.count' do

        post :create, message: email, format: :json

        assert_response :unprocessable_entity

      end
    end
  end

  test 'should get new ticket form in correct language' do
    I18n.locale = :nl
    get :new
    assert_response :success
    refute_match I18n.t('activerecord.attributes.ticket.from', locale: :nl), @response.body
  end

  test 'should get raw message' do
    sign_in users(:alice)

    @ticket.raw_message = fixture_file_upload('ticket_mailer/simple')
    @ticket.save!

    @ticket.reload
    get :show, id: @ticket.id, format: :eml
    assert_response :success
  end

  test 'should show replies even when ticket is locked' do
    sign_in users(:alice)

    @ticket.locked_by = users(:charlie)
    @ticket.locked_at = Time.now
    @ticket.save!

    get :show, id: @ticket.id
    assert_response :success
    assert_match replies(:solution).content, @response.body
  end

  test 'should mark new ticket from MTA as unread for all users' do
    assert_difference 'Ticket.count' do

      post :create, message: @simple_email, format: :json

      assert_response :success

      ticket = Ticket.last
      assert_not_nil ticket.unread_users.nil?
    end
  end

  test 'should mark new ticket as unread for all users' do
    assert_difference 'Ticket.count' do
      post :create, ticket: {
        from: 'test@test.nl',
        content: @ticket.content,
        subject: @ticket.subject,
      }

      assert_response :success

      ticket = Ticket.last

      assert_not_nil ticket.unread_users.nil?
    end
  end

  test 'should mark new ticket as unread for all users when posted from MTA' do
    assert_difference 'Ticket.count' do

      post :create, message: @simple_email, format: :json

      assert_response :success

      ticket = Ticket.last
      assert_not_nil ticket.unread_users
    end
  end

  test 'should mark ticket as read when clicked' do
    user = users(:alice)
    sign_in user
    ticket = Ticket.last
    ticket.unread_users << User.all
    assert_difference 'Ticket.last.unread_users.count', -1 do

      assert_not_nil ticket.unread_users

      get :show, id: ticket.id

      assert_response :success

      assert_not ticket.unread_users.include?(user)
    end
  end
end
