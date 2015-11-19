class AddDefaultToPaymentExpectedManufacture < ActiveRecord::Migration
  def change
    change_column_default :spt_ticket_spare_part_manufacture, :payment_expected_manufacture, 0
  end
end
