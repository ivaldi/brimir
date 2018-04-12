class AddFileToAttachment < ActiveRecord::Migration[4.2]
  def change
    change_table :attachments do |t|
      t.attachment :file
    end
  end
end
