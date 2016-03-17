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

class RepliesControllerTest < ActionController::TestCase

  setup do

    @ticket = tickets(:problem)
    @reply = replies(:solution)

    sign_in users(:alice)
  end

  test 'reply should always contain text' do
    # no emails should be send when invalid reply
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      assert_no_difference 'Reply.count' do

        user = users(:alice)
        user.signature = nil
        user.save

        post :create, reply: {
            content: '',
            ticket_id: @ticket.id,
            notified_user_ids: [users(:bob).id],
        }
      end
    end
  end

  test 'should send correct reply notification mail' do

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      post :create, reply: {
          content: '<br><br><p><strong>this is in bold</strong></p>',
          ticket_id: @ticket.id,
          notified_user_ids: User.agents.pluck(:id),
      }
    end

    mail = ActionMailer::Base.deliveries.last

    # html in the html part
    assert_match '<br><br><p><strong>this is in bold</strong></p>',
        mail.html_part.body.decoded

    # no html in the text part
    assert_match "\n\nthis is in bold\n", mail.text_part.body.decoded

    # correctly addressed
    assert_equal [User.agents.last.email], mail.to

    # correct content type
    assert_match 'multipart/alternative', mail.content_type

    # new reply link in body
    assert_match(I18n.translate(:view_new_reply), mail.text_part.body.decoded)

    # generated message id stored in db
    assert_not_nil assigns(:reply).message_id
  end

  test 'reply should have attachments' do

    assert_difference 'Attachment.count', 2 do
      post :create, reply: {
            content: '**this is in bold**',
            ticket_id: @ticket.id,
            notified_user_ids: [users(:bob).id],
            attachments_attributes: {
              '0' => { file: fixture_file_upload('attachments/default-testpage.pdf') },
              '1' => { file: fixture_file_upload('attachments/default-testpage.pdf') }
            }
      }
    end
  end

  test 'should be able to respond to others ticket as customer' do

    sign_out(users(:alice))
    sign_in(users(:dave))

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      post :create, reply: {
          content: 'test',
          ticket_id: @ticket.id,
          notified_user_ids: [users(:bob).id, users(:alice).id]
      }
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal users(:alice).email, mail.header_fields.select { |field| field.name == 'smtp-envelope-to' }.last.value
  end

  test 'should re-open ticket' do
    @ticket.status = 'closed'
    @ticket.save

    post :create, reply: {
        content: 're-open please',
        ticket_id: @ticket.id,
    }

    @ticket.reload
    assert_equal 'open', @ticket.status
  end

  test 'should get raw message' do
    @reply.raw_message = fixture_file_upload('ticket_mailer/simple')
    @reply.save!

    @reply.reload
    get :show, id: @reply.id, format: :eml
    assert_response :success
  end

end
