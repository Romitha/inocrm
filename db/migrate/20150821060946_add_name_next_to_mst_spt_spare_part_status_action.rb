class AddNameNextToMstSptSparePartStatusAction < ActiveRecord::Migration
  def change
    add_column :mst_spt_spare_part_status_action, :name_next, :string

    TicketSparePart
    [
      "",
      "To Be Ordered From Manufacturer",
      "To Be Collected From Manufacturer",
      "To Be Received From Manufacturer",
      "To Be Issued",
      "To Be Recieved By Engineer",
      "Part To Be Returned By Engineer",
      "Accept or Reject The Returned Part",
      "Accept or Reject The Returned Part",
      "Bundle The Part",
      "",
      "Complete The Estimation",
      "Approve The Estimation By Customer",
      "Request From Store",
      "Approve or Reject The Store Request",
      "Approve or Reject The Store Request",
      "Ready To Bundle"
    ].each_with_index do |value, index|
      SparePartStatusAction.find(index+1).update name_next: value
    end
  end
end
