class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notifiable, polymorphic: true, index: true
      t.references :user, index: true

      t.timestamps
    end
    add_index :notifications, [:notifiable_id, :notifiable_type, :user_id],
        unique: true,
        name: :unique_notification

    Reply.all.each do |reply|
      addresses = []

      addresses += reply.to.to_s.split(', ')
      addresses += reply.cc.to_s.split(', ')
      addresses += reply.bcc.to_s.split(', ')

      addresses.each do |address|
        u = User.where(email: address).first_or_initialize

        if u.new_record?
          password_length = 12
          password = Devise.friendly_token.first(password_length)

          u.password = password
          u.password_confirmation = password

          u.save!
          print "User created: #{u.email}\n"
        end

        reply.notified_users << u
      end

      reply.save!
    end

    remove_column :replies, :to
    remove_column :replies, :cc
    remove_column :replies, :bcc

  end
end
