class ModifyEstimationAndStoreAndSparePart < ActiveRecord::Migration
  def change
  	remove_column :spt_ticket_spare_part_non_stock, :estimation_required
  	remove_column :spt_ticket_spare_part_store, :estimation_required
  	remove_column :spt_ticket_spare_part_store, :ticket_estimation_part_id

  	add_column :spt_ticket_spare_part, :estimation_required, :boolean, default: false, null: false

  	add_column :spt_ticket_spare_part, :approved_estimation_part_id, "INT UNSIGNED NULL"
  	add_index :spt_ticket_spare_part, :approved_estimation_part_id, name: "fk_spt_ticket_spare_part_spt_ticket_estimation_part1_idx"
  	add_foreign_key :spt_ticket_spare_part, :spt_ticket_estimation_part, column: :approved_estimation_part_id, name: "fk_spt_ticket_spare_part_spt_ticket_estimation_part1"

  	add_column :spt_ticket, :note, :text
  end
end