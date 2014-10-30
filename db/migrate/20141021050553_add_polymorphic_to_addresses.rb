class AddPolymorphicToAddresses < ActiveRecord::Migration
  def up
    remove_column :addresses, :organization_id # remove_column does not supports for change method.
  end

  def change
    #Removing columns
    #remove_column :addresses, :organization_id # remove_column does not supports for change method.

    #Adding columns
    # add_column  :addresses, :addressable_id, :integer
    # add_column  :addresses, :addressable_type, :string

    add_reference :addresses, :addressable, polymorphic: true, index: true #this is short code for above adding columns

  end

end
