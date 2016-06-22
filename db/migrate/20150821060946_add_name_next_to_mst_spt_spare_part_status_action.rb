class AddNameNextToMstSptSparePartStatusAction < ActiveRecord::Migration
  def change
    add_column :mst_spt_spare_part_status_action, :name_next, :string
    end
  end
end
