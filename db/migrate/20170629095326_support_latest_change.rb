class SupportLatestChange < ActiveRecord::Migration
  def change
    add_column :spt_ticket_engineer, :sbu_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_engineer, :channel_no, :integer, null:false, default:1
    add_column :spt_ticket_engineer, :order_no, :integer, null:false, default:1

    [
      { table: :spt_ticket_engineer, column: :sbu_id, options: {name: "fk_spt_ticket_engineer_mst_spt_sbu_engineer1_idx"} },
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end

    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :spt_ticket_engineer, reference_table: :mst_spt_sbu_engineer, name: "fk_spt_ticket_engineer_mst_spt_sbu_engineer1", column: :sbu_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end
