class Currency < ActiveRecord::Base
	self.table_name = "mst_currency"
	has_many :product_brands, foreign_key: :currency_id
end
