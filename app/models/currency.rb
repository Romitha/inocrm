class Currency < ActiveRecord::Base
	self.table_name = "mst_currency"
	has_many :product_brands, foreign_key: :currency_id
  has_many :tickets, foreign_key: :manufacture_currency_id
  has_many :ticket_estimations, foreign_key: :currency_id

  has_many :ticket_spare_part_manufactures, foreign_key: :manufacture_currency_id
end
