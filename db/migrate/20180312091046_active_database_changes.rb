class ActiveDatabaseChanges < ActiveRecord::Migration
  def change
  	add_column :mst_spt_sla, :priority, :integer, null:false, default: 2
  	
	add_column :mst_spt_payment_term, :active, :boolean, null: false, default: 1

	add_column :mst_spt_pop_status, :active, :boolean, null: false, default: 1

	add_column :mst_spt_product_brand, :active, :boolean, null: false, default: 1

	add_column :mst_spt_product_category, :active, :boolean, null: false, default: 1

	add_column :mst_spt_product_category1, :active, :boolean, null: false, default: 1

	add_column :mst_spt_product_category2, :active, :boolean, null: false, default: 1

	add_column :mst_spt_reason, :active, :boolean, null: false, default: 1

	add_column :spt_problem_category, :active, :boolean, null: false, default: 1

	add_column :mst_spt_sla, :active, :boolean, null: false, default: 1

	add_column :mst_spt_spare_part_description, :active, :boolean, null: false, default: 1

	add_column :mst_spt_spare_part_status_use, :active, :boolean, null: false, default: 1

	add_column :mst_spt_ticket_informed_method, :active, :boolean, null: false, default: 1

	add_column :mst_spt_warranty_type, :active, :boolean, null: false, default: 1

	add_column :mst_tax, :active, :boolean, null: false, default: 1

	add_column :mst_title, :active, :boolean, null: false, default: 1

	add_column :mst_contact_person_type, :active, :boolean, null: false, default: 1

	add_column :mst_contact_types, :active, :boolean, null: false, default: 1

	add_column :mst_industry_types, :active, :boolean, null: false, default: 1

	add_column :mst_inv_bin, :active, :boolean, null: false, default: 1

	add_column :mst_inv_category1, :active, :boolean, null: false, default: 1

	add_column :mst_inv_category2, :active, :boolean, null: false, default: 1

	add_column :mst_inv_category3, :active, :boolean, null: false, default: 1

	add_column :mst_inv_disposal_method, :active, :boolean, null: false, default: 1

	add_column :mst_inv_manufacture, :active, :boolean, null: false, default: 1

	add_column :mst_inv_product_condition, :active, :boolean, null: false, default: 1

	add_column :mst_inv_rack, :active, :boolean, null: false, default: 1

	add_column :mst_inv_reason, :active, :boolean, null: false, default: 1

	add_column :mst_inv_shelf, :active, :boolean, null: false, default: 1

	add_column :mst_inv_unit, :active, :boolean, null: false, default: 1

	add_column :mst_inv_warranty_type, :active, :boolean, null: false, default: 1

	add_column :mst_organization_types, :active, :boolean, null: false, default: 1

	add_column :mst_spt_accessory, :active, :boolean, null: false, default: 1

	add_column :mst_spt_additional_charge, :active, :boolean, null: false, default: 1

	add_column :mst_spt_contact_type, :active, :boolean, null: false, default: 1

	add_column :mst_spt_contract_annexture, :active, :boolean, null: false, default: 1

	add_column :mst_spt_contract_brand_document, :active, :boolean, null: false, default: 1

	add_column :mst_spt_contract_status, :active, :boolean, null: false, default: 1

	add_column :mst_spt_customer_contact_type, :active, :boolean, null: false, default: 1

	add_column :mst_spt_customer_feedback, :active, :boolean, null: false, default: 1

	add_column :mst_spt_dispatch_method, :active, :boolean, null: false, default: 1

	add_column :mst_spt_extra_remark, :active, :boolean, null: false, default: 1

	add_column :mst_spt_job_type, :active, :boolean, null: false, default: 1

	add_column :mst_spt_onsite_type, :active, :boolean, null: false, default: 1

	add_column :mst_spt_payment_item, :active, :boolean, null: false, default: 1

	add_column :mst_spt_payment_received_type, :active, :boolean, null: false, default: 1

	add_column :designations, :active, :boolean, null: false, default: 1

	add_column :mst_dealer_types, :active, :boolean, null: false, default: 1
  end
end