class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.text :description
      t.boolean :auto_ticket_assign
      t.references :organization, index: true

      t.timestamps
    end
  end
end
