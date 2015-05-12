class AddCorrectionToDatabase < ActiveRecord::Migration
  def change
  	remove_column :dyna_columns, :id
  	add_column :dyna_columns, :id, "INT UNSIGNED"

  	remove_column :dyna_columns, :resourceable_id
  	add_column :dyna_columns, :resourceable_id, "INT UNSIGNED"
  end
end
