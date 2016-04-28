class AddColumsToSptActInformCustomer < ActiveRecord::Migration
  def change
    add_column :spt_act_inform_customer, :contact_address, :string
    add_column :spt_act_inform_customer, :subject, :string
  end
end
