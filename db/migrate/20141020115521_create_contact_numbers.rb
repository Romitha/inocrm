class CreateContactNumbers < ActiveRecord::Migration
  def change
    create_table :contact_numbers do |t|
      t.string :category
      t.string :value
      t.references :organization, index: true

      t.timestamps
    end
  end
end
