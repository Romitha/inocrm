class Product < ActiveRecord::Base
  self.table_name = "spt_product_serial"

  has_many :ticket_product_serial, foreign_key: :product_serial_id
  has_many :tickets, through: :ticket_product_serial

  belongs_to :product_brand, foreign_key: :product_brand_id
  belongs_to :product_category, foreign_key: :product_category_id
  belongs_to :product_pop_status, foreign_key: :pop_status_id
  belongs_to :product_sold_country, foreign_key: :sold_country_id
  belongs_to :inv_serial_item, foreign_key: :inventory_serial_item_id

  validates_presence_of [:serial_no, :product_brand_id, :product_category_id, :corparate_product]
end

class ProductBrand < ActiveRecord::Base
  self.table_name = "mst_spt_product_brand"

  has_many :products, foreign_key: :product_brand_id
  has_many :product_categories, foreign_key: :product_brand_id

  validates_presence_of [:name, :sla_time, :parts_return_days, :currency_id]
  belongs_to :currency, foreign_key: :currency_id

  validates_numericality_of [:sla_time, :parts_return_days]
end

class ProductCategory < ActiveRecord::Base
  self.table_name = "mst_spt_product_category"

  has_many :products, foreign_key: :product_category_id

  belongs_to :product_brand, foreign_key: :product_brand_id

  validates_presence_of [:product_brand_id, :name]
end

class ProductPopStatus < ActiveRecord::Base
  self.table_name = "mst_spt_pop_status"

  has_many :products, foreign_key: :pop_status_id
end

class ProductSoldCountry < ActiveRecord::Base
  self.table_name = "mst_country"

  has_many :products, foreign_key: :sold_country_id
end

class InvSerialItem < ActiveRecord::Base
  self.table_name = "inv_inventory_serial_item"

  has_many :products, foreign_key: :inventory_serial_item_id
end