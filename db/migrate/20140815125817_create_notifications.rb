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
        u = User.where(email: address).first_or_create!
        reply.notified_user_ids << u.id
      end

      reply.save!
    end

  end
end
