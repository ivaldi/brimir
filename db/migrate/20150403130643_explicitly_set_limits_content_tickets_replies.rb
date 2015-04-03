class ExplicitlySetLimitsContentTicketsReplies < ActiveRecord::Migration
  def change
    # make sure psql and mysql have the same limits
    change_column :tickets, :content, :text, limit: (1.gigabyte - 1)
    change_column :replies, :content, :text, limit: (1.gigabyte - 1)
  end
end
