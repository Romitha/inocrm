class AddStatusToUsers < ActiveRecord::Migration
  def change

    [:first_name, :last_name, :NIC, :user_name].each do |attribute|
      add_column :users, attribute, :string
    end

    [:state, :status, :permissions, :active].each do |attribute|
      add_column :users, attribute, :integer
    end


    [:created, :updated, :deleted].each do |attribute|
      add_reference :users, attribute, polymorphic: true
    end

    add_column :users, :deleted_at, :datetime
  end

end
