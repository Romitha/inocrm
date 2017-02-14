class Currency < ActiveRecord::Base
	self.table_name = "mst_currency"
  has_many :so_pos, foreign_key: :currency_id
	has_many :product_brands, foreign_key: :currency_id
  has_many :tickets, foreign_key: :manufacture_currency_id
  has_many :ticket_estimations, foreign_key: :currency_id

  has_many :ticket_spare_part_manufactures, foreign_key: :manufacture_currency_id
  has_many :grn_items

  has_many :inventory_product_info, foreign_key: :currency_id
  has_many :inventory_product_info, foreign_key: :currency_id
  has_many :act_terminate_job_payments

  has_many :inventory_serial_items_additional_cost, foreign_key: :currency_id
end