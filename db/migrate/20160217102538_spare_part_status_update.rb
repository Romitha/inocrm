class SparePartStatusUpdate < ActiveRecord::Migration
  def change

    add_column :spt_ticket_estimation_external, :description, :text
    add_column :mst_spt_spare_part_status_action, :non_stock_nc_type_index, :integer, null: false, default: 0
    add_column :mst_spt_spare_part_status_action, :non_stock_ch_type_index, :integer, null: false, default: 0
    add_column :mst_spt_spare_part_status_action, :manufacture_ch_type_index, :integer, null: false, default: 0
    TicketSparePart
    [
      [1, 1, 1, 1],
      [2, 4, 0, 0],
      [3, 5, 0, 0],
      [4, 6, 0, 0],
      [5, 7, 0, 0],
      [6, 8, 0, 0],
      [7, 9, 0, 0],
      [8, 10, 0, 0],
      [9, 10, 0, 0],
      [10, 12, 0, 0],
      [11, 13, 2, 4],
      [12, 2, 0, 2],
      [13, 3, 0, 3],
      [14, 0, 1, 0],
      [15, 0, 0, 0],
      [16, 0, 0, 0],
      [17, 11, 0, 0],
    ].each{ |value| SparePartStatusAction.find(value.first).update(manufacture_ch_type_index: value.second, non_stock_nc_type_index: value.third, non_stock_ch_type_index: value.fourth)}
  end
end
