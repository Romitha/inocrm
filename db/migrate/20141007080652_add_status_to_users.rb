class AddStatusToUsers < ActiveRecord::Migration
  def change

    [:first_name, :last_name, :NIC, :user_name, :name_title, :epf_no].each do |attribute|
      add_column :users, attribute, :string
    end

    [:state, :status, :permissions, :active].each do |attribute|
      add_column :users, attribute, :integer
    end


    [:created, :updated, :deleted].each do |attribute|
      add_reference :users, attribute, polymorphic: true
    end

    [:deleted_at, :date_joined_at].each do |attribute|
      add_column :users, attribute, :datetime
    end
  end

end
