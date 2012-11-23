class AddFileToAttachment < ActiveRecord::Migration
  def change
    change_table :attachments do |t|
      t.attachment :file
    end
  end
end
