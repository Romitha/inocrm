class RemoveCompulsoryOfRefStartPartId < ActiveRecord::Migration
  def change
    change_column_null :spt_ticket_on_loan_spare_part, :ref_spare_part_id, true

  end
end
