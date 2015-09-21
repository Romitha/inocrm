class Product < ActiveRecord::Base
  self.table_name = "spt_product_serial"

  mount_uploader :pop_doc_url, PopDocUrlUploader

  has_many :ticket_product_serials, foreign_key: :product_serial_id
  has_many :tickets, through: :ticket_product_serials
  has_many :warranties, foreign_key: :product_serial_id

  belongs_to :warranty_type, foreign_key: :product_brand_id
  belongs_to :product_brand, foreign_key: :product_brand_id
  belongs_to :product_category, foreign_key: :product_category_id
  belongs_to :product_pop_status, foreign_key: :pop_status_id
  belongs_to :product_sold_country, foreign_key: :sold_country_id
  belongs_to :inv_serial_item, foreign_key: :inventory_serial_item_id

  validates_presence_of [:serial_no, :product_brand_id, :product_category_id, :model_no, :product_no]

  def append_pop_status
    self.pop_note = "#{self.pop_note} <span class='pop_note_e_time'>(edited on #{Time.now.strftime('%d %b, %Y at %H:%M:%S')})</span><br/>#{pop_note_was}"
  end
end

class ProductBrand < ActiveRecord::Base
  self.table_name = "mst_spt_product_brand"

  has_many :products, foreign_key: :product_brand_id
  has_many :product_categories, foreign_key: :product_brand_id
  accepts_nested_attributes_for :product_categories, allow_destroy: true

  validates_presence_of [:name, :sla_time, :parts_return_days, :currency_id]
  belongs_to :currency, foreign_key: :currency_id
  belongs_to :sla_time, foreign_key: :sla_id

  validates_uniqueness_of :name

  validates_numericality_of [:parts_return_days]
end

class ProductCategory < ActiveRecord::Base
  self.table_name = "mst_spt_product_category"

  has_many :products, foreign_key: :product_category_id

  belongs_to :product_brand, foreign_key: :product_brand_id
  belongs_to :sla_time, foreign_key: :sla_id

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

class Accessory < ActiveRecord::Base
  self.table_name = "mst_spt_accessory"

  validates :accessory, presence: true, uniqueness: true
  has_many :ticket_accessories, foreign_key: :accessory_id
  has_many :tickets, through: :ticket_accessories
end

class RepairType < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_repair_type"

  has_many :tickets, foreign_key: :repair_type_id
end