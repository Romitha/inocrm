class TableAlteration01 < ActiveRecord::Migration
  def change
    #Removing columns
    remove_column :addresses, :organization_id

    #Adding columns
    add_column  :addresses, :addressable_id, :integer
    add_column  :addresses, :addressable_type, :string

  end
end
