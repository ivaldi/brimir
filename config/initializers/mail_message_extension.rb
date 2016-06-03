require 'mail'

Mail::Message.send(:prepend, MailMessageExtension)
