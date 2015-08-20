class AddCreateAtAndCreatedByToSptTicketSparePart < ActiveRecord::Migration
  def change
    add_column :spt_ticket_spare_part, :requested_at, :datetime
    add_column :spt_ticket_spare_part, :requested_by, :integer

    # add_index :spt_ticket_spare_part, :requested_by, unique: true

    # add_foreign_key :spt_ticket_spare_part, :users, name: "fk_spt_act_request_spare_part_users", column: :requested_by
  end
end
