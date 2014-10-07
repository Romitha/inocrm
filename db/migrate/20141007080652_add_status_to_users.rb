class AddStatusToUsers < ActiveRecord::Migration
  def change

    [:first_name, :last_name, :NIC, :user_name].each do |attribute|
      add_column :users, attribute, :string
    end

    [:state, :status, :organization_id, :titles_id, :designation_id, :accounts_id, :role_id,
     :permissions, :active , :created_by, :updated_by, :deleted_by].each do |attribute|
      add_column :users, attribute, :integer
    end

    add_column :users, :deleted_at, :datetime
  end

end
