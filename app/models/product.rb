class Product < ActiveRecord::Base
  self.table_name = "spt_product_serial"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :tickets, type: "nested", include_in_parent: true
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: 5) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          # must { range :published_at, lte: Time.zone.now }
          # must { term :author_id, params[:author_id] } if params[:author_id].present?
        end
      end
      sort { by :created_at, "desc" } if params[:query].blank?
      highlight :serial_no, :options => { :tag => '<strong class="highlight">' } if params[:query].present?
    end
      # query { string params[:query] } if params[:query].present?

      # filter :range, published_at: { lte: Time.zone.now} 
      # raise to_curl
  end

  def to_indexed_json
    Warranty
    to_json(
      only: [:id, :serial_no, :model_no, :product_no, :created_at],
      methods: [:category_name, :warranty_type_name, :brand_name],
      include: {
        tickets: {
          only: [:created_at, :cus_chargeable, :id],
          methods: [:customer_name, :ticket_status_name, :warranty_type_name, :support_ticket_no],
        },
        product_pop_status: {
          only: [:name, :code]
        }
      }
    )

  end

  def category_name
    product_category.name
  end

  def warranty_type_name
    warranty_type.name
  end

  def brand_name
    product_brand.name
  end

  mount_uploader :pop_doc_url, PopDocUrlUploader

  has_many :ticket_product_serials, foreign_key: :product_serial_id
  accepts_nested_attributes_for :ticket_product_serials, allow_destroy: true

  has_many :tickets, through: :ticket_product_serials
  has_many :warranties, foreign_key: :product_serial_id
  has_many :ref_product_serials, class_name: "TicketProductSerial", foreign_key: :ref_product_serial_id
  accepts_nested_attributes_for :ref_product_serials, allow_destroy: true

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

  has_many :return_parts_bundles

  validates_presence_of [:name, :sla_time, :parts_return_days, :currency_id]
  belongs_to :currency, foreign_key: :currency_id
  belongs_to :sla_time, foreign_key: :sla_id
  belongs_to :supplier, class_name: "Organization", foreign_key: :organization_id

  validates_uniqueness_of :name

  validates_numericality_of [:parts_return_days]

  def is_used_anywhere?
    TicketSparePart
    products.any? or product_categories.any? or return_parts_bundles.any?
  end
end

class ProductCategory < ActiveRecord::Base
  self.table_name = "mst_spt_product_category"

  has_many :products, foreign_key: :product_category_id

  belongs_to :product_brand, foreign_key: :product_brand_id
  belongs_to :sla_time, foreign_key: :sla_id

  validates_presence_of [:name]

  def is_used_anywhere?
    products.any?
  end
end

class ProductPopStatus < ActiveRecord::Base
  self.table_name = "mst_spt_pop_status"

  has_many :products, foreign_key: :pop_status_id
end

class ProductSoldCountry < ActiveRecord::Base
  self.table_name = "mst_country"

  validates :Country, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  has_many :products, foreign_key: :sold_country_id

  has_many :inventory_product_info, foreign_key: :country_id

  has_many :addresses
  has_many :contact_numbers

  def is_used_anywhere?
    Inventory
    products.any? or inventory_product_info.present?
  end


end

class InvSerialItem < ActiveRecord::Base
  self.table_name = "inv_inventory_serial_item"

  has_many :products, foreign_key: :inventory_serial_item_id
end

class Accessory < ActiveRecord::Base
  Ticket
  self.table_name = "mst_spt_accessory"

  validates :accessory, presence: true, uniqueness: true
  has_many :ticket_accessories, foreign_key: :accessory_id
  has_many :tickets, through: :ticket_accessories

  validates_uniqueness_of :accessory, case_sensitive: false

  def is_used_anywhere?
    ticket_accessories.any? or tickets.any? 
  end
end

# class RepairType < ActiveRecord::Base
#   self.table_name = "mst_spt_ticket_repair_type"

#   has_many :tickets, foreign_key: :repair_type_id
# end