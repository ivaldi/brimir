class SetCorrectDefaultContentTypes < ActiveRecord::Migration[4.2]
  def change
    change_column_default :replies, :content_type, 'html'
  end
end
