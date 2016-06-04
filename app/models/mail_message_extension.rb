# This is prepended to Mail::Message.
# https://github.com/mikel/mail/blob/master/lib/mail/message.rb
#
module MailMessageExtension

  def deliver
    Rails.logger.info "Sending mail smtp_envelope_to #{self.smtp_envelope_to.to_s}."
    return super
  end

  def smtp_envelope_to
    (header_fields.select { |field| field.name == 'smtp-envelope-to' }.count <= 1) || raise('There should be only one smtp-envelope-to header field.')
    header_fields.select { |field| field.name == 'smtp-envelope-to' }.last.try(:value) || super
  end

end
