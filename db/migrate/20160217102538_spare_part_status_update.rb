class SparePartStatusUpdate < ActiveRecord::Migration
  def change

    add_column :spt_ticket_estimation_external, :description, :text
    add_column :mst_spt_spare_part_status_action, :non_stock_nc_type_index, :integer, null: false, default: 0
    add_column :mst_spt_spare_part_status_action, :non_stock_ch_type_index, :integer, null: false, default: 0
    add_column :mst_spt_spare_part_status_action, :manufacture_ch_type_index, :integer, null: false, default: 0
  end
end
