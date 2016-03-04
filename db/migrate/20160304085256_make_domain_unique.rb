class MakeDomainUnique < ActiveRecord::Migration
  def change
    add_index :tenants, :domain, unique: true
  end
end
