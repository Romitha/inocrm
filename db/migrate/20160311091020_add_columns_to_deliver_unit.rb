class AddColumnsToDeliverUnit < ActiveRecord::Migration
  def change
    add_column :spt_ticket_deliver_unit, :estimation_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_deliver_unit, :supplier_paid_by, "INT UNSIGNED NULL"
    add_column :spt_ticket_deliver_unit, :supplier_paid, :boolean, null: false, default: false
    add_column :spt_ticket_deliver_unit, :supplier_paid_at, :datetime

    add_index :spt_ticket_deliver_unit, :estimation_id, name: :fk_spt_ticket_deliver_unit_spt_ticket_estimation1_idx
    add_index :spt_ticket_deliver_unit, :supplier_paid_by, name: :fk_spt_ticket_deliver_unit_users5_idx

    add_foreign_key :spt_ticket_deliver_unit, :spt_ticket_estimation, column: :estimation_id, name: :fk_spt_ticket_deliver_unit_spt_ticket_estimation1
    add_foreign_key :spt_ticket_deliver_unit, :users, column: :supplier_paid_by, name: :fk_spt_ticket_deliver_unit_users5
  end
end