class AddSupEstimationQuotationRequiredToCompanyConfig < ActiveRecord::Migration
  def change

	add_column :company_config, :sup_estimation_quotation_required, :boolean, null: false, default: true
    add_column :spt_ticket, :qc_passed_at, :datetime, null: true 

    add_column :spt_ticket_spare_part, :available_mail_sent_at, :datetime, null: true 
    add_column :spt_ticket_spare_part, :available_mail_sent_by, "INT UNSIGNED NULL"

    add_index :spt_ticket_spare_part, :available_mail_sent_by, name: "ind_spt_ticket_spare_part_available_mail_sent_by_id"
    add_foreign_key :spt_ticket_spare_part, :users, name: "fk_spt_ticket_spare_part_available_mail_sent_by_id", column: :available_mail_sent_by

  end
end
