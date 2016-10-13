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

class NotificationMailer < ActionMailer::Base

  add_template_helper HtmlTextHelper

  def self.incoming_message(ticket_or_reply, original_message)
    if ticket_or_reply.is_a? Reply
      reply = ticket_or_reply
      reply.set_default_notifications!(original_message)
      reply.notification_mails.each(&:deliver_now)
    else
      ticket = ticket_or_reply

      Rule.apply_all ticket

      # where user notifications added?
      if ticket.notified_users.count == 0
        ticket.set_default_notifications!
      end

      if ticket.assignee.nil?
        ticket.notified_users.each do |user|
          message = NotificationMailer.new_ticket(ticket, user)
          message.message_id = "<#{ticket.message_id}>"
          message.deliver_now unless EmailAddress.pluck(:email).include?(user.email)

          ticket.message_id = message.message_id if ticket.message_id.nil?
        end

        ticket.save
      else
        NotificationMailer.assigned(ticket).deliver_now
      end
    end

    original_message = Mail.new(original_message)

    # store original cc/to users as well
    (original_message.to.to_a + original_message.cc.to_a).each do |email|
      next if EmailAddress.pluck(:email).include?(email)

      user = User.find_first_by_auth_conditions(email: email)
      if user.nil?
        ticket_or_reply.notified_users << User.create(email: email)
      else
        next if ticket_or_reply.notified_users.include?(user)
        ticket_or_reply.notified_users << user
      end
    end
  end

  def new_account(user, template, tenant)
    if tenant.notify_user_when_account_is_created
      return unless template.is_active?
      @template = template
      @domain = tenant.domain
      @user = user

      mail(to: user.email, from: tenant.from, subject: I18n.t('new_account_subject'))
    end
  end

  def new_ticket(ticket, user)
    unless user.locale.blank?
      @locale = user.locale
    else
      @locale = Rails.configuration.i18n.default_locale
    end
    title = I18n::translate(:new_ticket, locale: @locale) + ': ' + ticket.subject.to_s

    add_attachments(ticket)

    unless ticket.message_id.blank?
      headers['Message-ID'] = "<#{ticket.message_id}>"
    end

    @ticket = ticket
    @user = user

    mail(to: user.email, subject: title, from: ticket.reply_from_address)
  end

  def new_reply(reply, user)
    unless user.locale.blank?
      @locale = user.locale
    else
      @locale = Rails.configuration.i18n.default_locale
    end
    title = I18n::translate(:new_reply, locale: @locale) + ': ' + reply.ticket.subject

    add_attachments(reply)
    add_reference_message_ids(reply)
    add_in_reply_to_message_id(reply)

    unless reply.message_id.blank?
      headers['Message-ID'] = "<#{reply.message_id}>"
    end

    @reply = reply
    @user = user
    return if EmailAddress.pluck(:email).include?(user.email.to_s)

    displayed_to_field = reply.notified_users.where(agent: false).pluck(:email)
    displayed_to_field = user.email if displayed_to_field.empty?

    message = mail(smtp_envelope_to: user.email, to: displayed_to_field,
      subject: title, from: reply.ticket.reply_from_address)
    message.smtp_envelope_to = user.email
    return message
  end

  def status_changed(ticket)
    @ticket = ticket

    unless ticket.message_id.blank?
      headers['Message-ID'] = "<#{ticket.message_id}>"
    end
    mail(to: ticket.assignee.email, subject:
        'Ticket status modified in ' + ticket.status + ' for: ' \
        + ticket.subject, from: ticket.reply_from_address)
  end

  def priority_changed(ticket)
    @ticket = ticket

    unless ticket.message_id.blank?
      headers['Message-ID'] = "<#{ticket.message_id}>"
    end
    mail(to: ticket.assignee.email, subject:
        'Ticket priority modified in ' + ticket.priority + ' for: ' \
        + ticket.subject, from: ticket.reply_from_address)
  end

  def assigned(ticket)
    @ticket = ticket

    unless ticket.message_id.blank?
      headers['Message-ID'] = "<#{ticket.message_id}>"
    end
    mail(to: ticket.assignee.email, subject:
        'Ticket assigned to you: ' + ticket.subject, from: ticket.reply_from_address)
  end


  protected
    def add_reference_message_ids(reply)
      references = reply.other_replies.with_message_id.pluck(:message_id)

      if references.count > 0
        headers['References'] = '<' + references.join('> <') + '>'
      end
    end

    def add_in_reply_to_message_id(reply)

      last_reply = reply.other_replies.order(:id).last

      if last_reply.nil?
        headers['In-Reply-To'] = '<' + reply.ticket.message_id.to_s + '>'
      else
        headers['In-Reply-To'] = '<' + last_reply.message_id.to_s + '>'
      end

    end

    def add_attachments(ticket_or_reply)
      ticket_or_reply.attachments.each do |at|
        attachments[at.file_file_name] = File.read(at.file.path)
      end
    end

end
