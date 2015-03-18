class Product < ActiveRecord::Base
  self.table_name = "spt_product_serial"

  has_many :ticket_product_serial, foreign_key: :product_serial_id
  has_many :tickets, through: :ticket_product_serial

  belongs_to :product_brand, foreign_key: :product_brand_id
  belongs_to :product_category, foreign_key: :product_category_id

  validates_presence_of [:serial_no, :product_brand_id, :product_category_id, :corparate_product]
end

class ProductBrand < ActiveRecord::Base
  self.table_name = "mst_spt_product_brand"

  has_many :products, foreign_key: :product_brand_id
  has_many :product_categories, foreign_key: :product_brand_id

  validates_presence_of [:name, :sla_time, :parts_return_days, :currency_id]
end

class ProductCategory < ActiveRecord::Base
  self.table_name = "mst_spt_product_category"

  has_many :products, foreign_key: :product_category_id

  belongs_to :product_brand, foreign_key: :product_brand_id

  validates_presence_of [:product_brand_id, :name]
end