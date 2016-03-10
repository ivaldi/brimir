class MakeDomainUnique < ActiveRecord::Migration
  def change
    unless index_exists?(:tenants, :domain)
      add_index :tenants, :domain, unique: true
    end
  end
end
