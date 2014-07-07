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

require 'test_helper'

class RepliesControllerTest < ActionController::TestCase

  setup do

    @ticket = tickets(:problem)
    @reply = replies(:solution)

    sign_in users(:alice)
  end

  test 'should notify agents when reply is added by customer' do
    sign_out users(:alice)
    sign_in users(:bob)

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, reply: {
          content: @reply.content,
          ticket_id: @ticket.id,
          to: @reply.to
      }
    end

    mail = ActionMailer::Base.deliveries.last

    assert_match(/New reply received for/, mail.body.decoded)

    assert_not_nil assigns(:reply).message_id

  end

  test 'should send reply when reply is added by agent' do

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, reply: {
          content: @reply.content,
          ticket_id: @ticket.id,
          to: @reply.to
      }
    end

    mail = ActionMailer::Base.deliveries.last

    assert_match @reply.content, mail.text_part.body.decoded

    assert_match 'multipart/alternative', mail.content_type

    assert_not_nil assigns(:reply).message_id

  end

  test 'reply should always contain text' do

    # no emails should be send when invalid reply
    assert_no_difference 'ActionMailer::Base.deliveries.size' do      
      post :create, reply: {
          content: '',
          ticket_id: @ticket.id,
          to: @reply.to
      }
    end

    refute_equal 0, assigns(:reply).errors.size

  end

  test 'reply should contain signature' do

    post :create, reply: {
        content: @reply.content,
        ticket_id: @ticket.id,
        to: @reply.to
    }

    mail = ActionMailer::Base.deliveries.last

    assert_match assigns(:reply).user.signature, mail.text_part.body.decoded
  end

  test 'should send reply to correct to, cc and bcc addresses' do

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, reply: {
          content: @reply.content,
          ticket_id: @ticket.id,
          to: @reply.to,
          cc: @reply.cc,
          bcc: @reply.bcc
      }
    end

    mail = ActionMailer::Base.deliveries.last

    assert_match @reply.content, mail.text_part.body.decoded

    assert_equal [ @reply.to ], mail.to
    assert_equal [ @reply.cc ], mail.cc
    assert_equal [ @reply.bcc ], mail.bcc

  end

  test 'reply should have text and html' do
    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, reply: {
          content: '<br/><br /><p><strong>this is in bold</strong></p>',
          ticket_id: @ticket.id,
          to: @reply.to,
      }
    end

    mail = ActionMailer::Base.deliveries.last
    # html in the html part
    assert_match '<br/><br /><p><strong>this is in bold</strong></p>',
        mail.html_part.body.decoded

    # no html in the text part
    assert_match "\n\nthis is in bold\n", mail.text_part.body.decoded
  end

  test 'reply should have attachments' do

    assert_difference 'Attachment.count', 2 do
      post :create, reply: {
            content: '**this is in bold**',
            ticket_id: @ticket.id,
            to: @reply.to,
        },
        attachment: [
            fixture_file_upload('attachments/default-testpage.pdf'),
            fixture_file_upload('attachments/default-testpage.pdf')
        ]
    end
  end

  test 'should send reply to correct to when not posted' do

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, reply: {
          content: @reply.content,
          ticket_id: @ticket.id,
      }
    end

    mail = ActionMailer::Base.deliveries.last

    assert_equal [ @ticket.user.email ], mail.to

  end


end
