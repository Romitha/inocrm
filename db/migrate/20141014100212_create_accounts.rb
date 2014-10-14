class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
		t.datetime 		:created_at
		t.integer 		:created_by#,      limit: 11
		t.integer 		:industry_types_id#,      limit: 11
		t.boolean 		:deleted
    end
  end
end
