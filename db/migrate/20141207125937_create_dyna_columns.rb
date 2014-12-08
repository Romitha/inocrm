class CreateDynaColumns < ActiveRecord::Migration
  def change
    create_table :dyna_columns do |t|
      t.string :data_key
      t.string :data_value
      t.references :resourceable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
