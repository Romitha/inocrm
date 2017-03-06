class Inventory < ActiveRecord::Base
  self.table_name = "inv_inventory"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  # mapping do
  #   indexes :tickets, type: "nested", include_in_parent: true
  # end

  def self.search(params)
    tire.search(page: params[:page], per_page: 10) do
      query do
        boolean do
          # must { string params[:grn_no] } if params[:grn_no].present?
          must { term :store_id, params[:store_id] } if params[:store_id].present?
          must { term :product_id, params["search_inventory[product]"] } if params["search_inventory[product]"].present?

          # must { range :formated_created_at, lte: params[:range_to].to_date } if params[:range_to].present?
          # must { range :formated_created_at, gte: params[:range_from].to_date } if params[:range_from].present?
          # filter :range, published_at: { lte: Time.zone.now}
          # raise to_curl
        end
      end
      # sort { by :grn_no, "asc" }
    end
  end

  def to_indexed_json
    to_json(
      only: [:id, :store_id, :stock_quantity, :reserved_quantity, :max_quantity],
      methods: [:store_name]
      # include: {
      #   created_by_user: {
      #     methods: [:full_name],
      #   }
      # }
    )

  end

  # def to_indexed_json
  #   to_json(
  #     only: [:id, :store_id, :grn_no, :created_by, :remarks, :po_no, :supplier_id],
  #     methods: [:store_name, :supplier_name, :grn_no_format, :formated_created_at],
  #     include: {
  #       created_by_user: {
  #         methods: [:full_name],
  #       }
  #     }
  #   )

  # end

  # def grn_no_format
  #   grn_no.to_s.rjust(5, INOCRM_CONFIG["inventory_grn_no_format"])
  # end

  def store_name
    organization.name
  end

  def product_stock_cost
    inventory_product.stock_cost(id)
  end

  def inventory_stock_quantity
    inventory_product.product_stock_quantity(id)
  end

  belongs_to :organization, -> { where(type_id: 4) }, foreign_key: :store_id
  belongs_to :inventory_product, foreign_key: :product_id

  has_many :inventory_serial_items

  belongs_to :inventory_bin, foreign_key: :bin_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by
  belongs_to :updated_by_user, class_name: "User", foreign_key: :updated_by

  validates_presence_of [:store_id, :product_id, :stock_quantity, :available_quantity, :reserved_quantity, :created_by]

  after_save :update_relation_index

  before_save :reset_values

  def update_relation_index

    [:inventory_product].each do |parent|
      send(parent).update_index

      # parent.to_s.classify.constantize.find(self.send(parent).id).grn_items.each{ |grn_item| grn_item.update_relation_index }

    end
  end

  def reset_values
    if (["stock_quantity", "available_quantity"] & changed).present?
      Rails.cache.delete([:stock_cost, product_id, id ])

    end
  end
end

class InventoryProduct < ActiveRecord::Base
  self.table_name = "mst_inv_product"

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html will be describing more...
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :inventory_category3, foreign_key: :category3_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by
  belongs_to :updated_by_user, class_name: "User", foreign_key: :updated_by

  has_many :inventories, foreign_key: :product_id
  has_many :stores, through: :inventories, source: :organization

  belongs_to :inventory_unit, foreign_key: :unit_id
  has_many :inventory_serial_items, foreign_key: :product_id
  has_many :inventory_serial_parts, foreign_key: :product_id
  has_many :inventory_batches, foreign_key: :product_id
  has_many :inventory_grn_batches, through: :inventory_batches, source: :grn_batches

  has_one :inventory_product_info, foreign_key: :product_id
  accepts_nested_attributes_for :inventory_product_info, allow_destroy: true

  has_many :ticket_spare_part_stores, foreign_key: :inv_product_id

  has_many :grn_items, foreign_key: :product_id
  has_many :grn_serial_items, through: :grn_items
  has_many :grn_batches, through: :grn_items
  has_many :only_grn_items, -> { joins(:grn_serial_items, :grn_batches).where("inv_grn_batch.grn_item_id = :id AND inv_grn_serial_item.grn_item_id = :id", {id: nil} ) }, class_name: "GrnItem", foreign_key: :product_id

  has_many :ticket_spare_part_non_stocks, foreign_key: :inv_product_id
  has_many :approved_ticket_spare_part_non_stocks, class_name: "TicketSparePartNonStock", foreign_key: :approved_inv_product_id

  has_many :inventory_prn_items, foreign_key: :product_id
  accepts_nested_attributes_for :inventory_prn_items, allow_destroy: true
  has_many :inventory_prns, through: :inventory_prn_items
  has_many :inventory_po_items, through: :inventory_prn_items

  has_many :srn_items, foreign_key: :product_id do
    def by_store(store_id)
      joins(:srn).where("inv_srn.store_id = ?", store_id)
    end
  end

  has_many :gin_items, foreign_key: :product_id do
    def by_store(store_id)
      joins(:gin).where("inv_gin.store_id = ?", store_id)
    end
  end

  validates_presence_of [:unit_id, :category3_id, :serial_no]
  validates_uniqueness_of :serial_no, scope: :category3_id
  validates :serial_no, :length => { :maximum => 6 }

  has_many :dyna_columns, as: :resourceable, autosave: true

  after_save do |inventory_product|
    inventory_product.generated_code = inventory_product.generated_item_code

  end

  [:generated_code, :type_count].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save if data.persisted?
    end
  end

  def is_used_anywhere?
    inventory_category3.present? or inventories.any? or inventory_unit.present? or inventory_serial_items.any? or inventory_product_info.present? or ticket_spare_part_stores.any? or grn_items.any? or inventory_serial_parts.any? or inventory_serial_items.any? or ticket_spare_part_non_stocks.any? or approved_ticket_spare_part_non_stocks.any?
  end

  def generated_item_code
    Organization
   "#{inventory_category3.inventory_category2.inventory_category1.code}#{CompanyConfig.first.inv_category_seperator}#{inventory_category3.inventory_category2.code}#{CompanyConfig.first.inv_category_seperator}#{inventory_category3.code}#{CompanyConfig.first.inv_category_seperator}#{serial_no.to_s.rjust(6, INOCRM_CONFIG["inventory_serial_no_format"])}"
  end


  def generated_serial_no
    serial_no.to_s.rjust(5, INOCRM_CONFIG["inventory_serial_no_format"])
  end

  def generated_serial_no=(generated_serial_no)
    self.serial_no = generated_serial_no.to_s.rjust(5, INOCRM_CONFIG["inventory_serial_no_format"])
  end

  def category3_id
    inventory_category3.try :id
  end

  def category2_id
    inventory_category3.inventory_category2.id
  end

  def category1_id
    inventory_category3.inventory_category2.inventory_category1.id
  end

  def category3_name
    inventory_category3.try :name
  end

  def category2_name
    inventory_category3.inventory_category2.name
  end

  def category1_name
    inventory_category3.inventory_category2.inventory_category1.name
  end

  def last_prn_item
    inventory_prn_items.last
  end

  def last_po_item
    inventory_po_items.last
  end
  def created_by_from_user
    created_by_user.full_name
  end

  def updated_by_from_user
    updated_by_user.full_name
  end

  def manufacture
    inventory_product_info and inventory_product_info.manufacture.try(:manufacture)
  end

  def stock_cost(inventory_id = nil)
    # product_type_count = if inventory_product_info.need_serial
    #   grn_serial_items.active_serial_items.to_a.count

    # elsif inventory_product_info.need_batch
    #   grn_batches.to_a.count

    # else
    #   grn_items.only_grn_items1.count

    # end

    # if product_type_count.to_i != self.type_count.to_i

    #   Rails.cache.delete([:stock_cost, self.id, inventory_id.to_i ])

    #   self.type_count = product_type_count

    #   self.save if self.type_count.nil?

    # end

    Rails.cache.fetch([:stock_cost, id, inventory_id.to_i ]) do
      stock_cost = if inventory_product_info.need_serial
        grn_serial_items.active_serial_items.to_a.sum{|g| g.inventory_serial_item.inventory_id == inventory_id ? (g.grn_item.current_unit_cost.to_f + g.inventory_serial_item.inventory_serial_items_additional_costs.to_a.sum{|c| c.cost.to_f }) : 0 }

      elsif inventory_product_info.need_batch
        grn_batches.to_a.sum{|g| g.inventory_batch.inventory_id == inventory_id ? (g.grn_item.current_unit_cost.to_f * g.remaining_quantity.to_f) : 0 }

      else
        store_id = inventories.where(id: inventory_id).first.try(:store_id)

        grn_items.only_grn_items1.to_a.sum{|g| g.grn.store_id == store_id ? g.remaining_quantity.to_f * g.current_unit_cost.to_f : 0 }

      end

      stock_cost
    end

  end

  def product_stock_quantity(inventory_id = nil)
    inventories.find_by_id(inventory_id).try(:stock_quantity).to_f
  end

  def product_type
    label = if non_stock_item
      "Non Stock Item"
    end

    label_type = case
    when inventory_product_info.need_serial
      "Serial"
    when inventory_product_info.need_batch
      "Batch"
    else
      "Non Serial Non Batch"
    end

    [label, label_type].compact.join(" ")

  end

  mapping do
    indexes :inventory_product_info, type: "nested", include_in_parent: true
    indexes :inventory_unit, type: "nested", include_in_parent: true
    indexes :stores, type: "nested", include_in_parent: true
    indexes :grn_items, type: "nested", include_in_parent: true
    indexes :only_grn_items, type: "nested", include_in_parent: true
    indexes :grn_batches, type: "nested", include_in_parent: true
    indexes :grn_serial_items, type: "nested", include_in_parent: true
    indexes :inventory_batches, type: "nested", include_in_parent: true
    # indexes :inventories, type: "nested", include_in_parent: true
    indexes :inventories, type: "nested", include_in_parent: true do
      indexes :product_stock_cost, type: "double"
    end

    indexes :product_type, type: "string", analyzer: "keyword"


  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          # must { term "stores.id", params[:store_id] } if params[:store_id].present?
          # puts params[:store_id]
        end
      end
      #((((((((()))))))))
      sort { by (params[:order_by_field] || :generated_item_code), {order: "#{params[:order] or 'asc'}", ignore_unmapped: true} }
      #((((((((()))))))))

      # #***************************************************************************
      # sort { by :generated_item_code, {order: "asc", ignore_unmapped: true} }
      # #***************************************************************************



      # filter :range, published_at: { lte: Time.zone.now}
      highlight :description => { :number_of_fragments => 3 }, :options => { :tag => "<strong class='highlight'>" }
      # raise to_curl
    end
  end

  def self.advance_search(params)
    query = params[:query]

    options = {
      "query" =>  {
        "bool" => {
          "must" => [
            {
              "query_string" => {
                "query" =>  query
              }
            }
          ]
        }
      },
      "sort" => [
        {
          "generated_item_code" => {
            "order" => "asc",
            "ignore_unmapped" => true
          }
        }
      ],
      "aggs" =>  {
        "stock_cost" =>  {
          "sum" =>  {
            "field" =>  "inventories.product_stock_cost"
          }
        }
      },
      "size" => 10,
      "from" => 0
    }

    r = Tire.search('inventory_products', options)
    HashToObject.new r.json
    
  end

  def to_indexed_json
    Product
    Inventory
    to_json(
      only: [:id, :description, :model_no, :product_no, :spare_part_no, :fifo, :created_at, :serial_no, :remarks, :created_by_user, :updated_by_user],
      methods: [:category3_id, :category2_id, :category1_id, :category3_name, :category2_name, :category1_name, :generated_serial_no, :generated_item_code, :created_by_from_user, :updated_by_from_user, :manufacture, :product_type],

      include: {
        inventory_unit: {
          only: [:unit],
        },
        inventory_product_info: {
          only: [:need_serial, :need_batch],
          methods: [:currency_type],
          include: {
            manufacture: {
              only: [:manufacture, :need_serial, :need_batch, :remarks, :currency_id],
              methods: [:currency_type],
            },
            product_sold_country: {
              only: [:Country],
            },
          },
        },
        stores: {
          only: [:name, :id]
        },
        inventories: {
          only: [:id, :store_id, :product_id, :stock_quantity, :available_quantity],
          methods: [:product_stock_cost]
        },
        inventory_serial_items: {
          only: [:id, :product_id],
          include: {
            grn_items: {
              only: [:id, :current_unit_cost, :remaining_quantity],
              methods: [:any_remaining_serial_item],
            },
            inventory_serial_items_additional_costs: {
              only: [:id, :cost],
            },
          },
        },
        grn_batches: {
          only: [:id, :remaining_quantity],
          include: {
            grn_item: {
              only: [:current_unit_cost]
            },
          },
        },
        grn_serial_items: {
          only: [:id, :remaining],
          include: {
            grn_item: {
              only: [:current_unit_cost]
            },
            inventory_serial_item:{
              only:[:id],
              include: {
                inventory_serial_items_additional_costs:{
                  only:[:id, :cost],
                },
              },
            },
          },
        },
        grn_items: {
          only: [:id, :current_unit_cost, :remaining_quantity],
          include: {
            grn: {
              only: [:grn_no, :currency_id, :created_at, :store_id],
            },
          },
        },
      }
    )

  end

end

class InventoryProductInfo < ActiveRecord::Base
  self.table_name = "mst_inv_product_info"

  mount_uploader :picture, ProductInfoUploader

  belongs_to :inventory_product, foreign_key: :product_id

  belongs_to :manufacture, foreign_key: :manufacture_id

  belongs_to :product_sold_country, foreign_key: :country_id

  belongs_to :currency, foreign_key: :currency_id

  belongs_to :inventory_unit, foreign_key: :secondary_unit_id

  belongs_to :product_sold_country, foreign_key: :country_id

  def currency_type
    currency.code
  end

end

class InventoryCategory1 < ActiveRecord::Base
  self.table_name = "mst_inv_category1"

  has_many :inventory_category2s, foreign_key: :category1_id
  accepts_nested_attributes_for :inventory_category2s, allow_destroy: true
  has_many :inventory_category3s, through: :inventory_category2s

  def is_used_anywhere?
    inventory_category2s.any?
  end

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

end

class InventoryCategory2 < ActiveRecord::Base
  self.table_name = "mst_inv_category2"

  belongs_to :inventory_category1, foreign_key: :category1_id

  has_many :inventory_category3s, foreign_key: :category2_id
  accepts_nested_attributes_for :inventory_category3s, allow_destroy: true

  has_many :inventory_products, through: :inventory_category3s

  def is_used_anywhere?
    inventory_category3s.any? or inventory_products.any?
  end

  validates :name, presence: true
  validates :code, presence: true
  validates_uniqueness_of :name, scope: [:code, :category1_id]
  validates_uniqueness_of :code, scope: [:name, :category1_id]

end

class InventoryCategory3 < ActiveRecord::Base
  self.table_name = "mst_inv_category3"

  belongs_to :inventory_category2, foreign_key: :category2_id
  has_many :inventory_products, foreign_key: :category3_id

  def is_used_anywhere?
    inventory_products.any?
  end

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates_uniqueness_of :name, scope: [:code, :category2_id]
  validates_uniqueness_of :code, scope: [:name, :category2_id]
end

class InventoryCategoryCaption < ActiveRecord::Base
  self.table_name = "mst_inv_category_caption"
end

class Manufacture < ActiveRecord::Base
  self.table_name = "mst_inv_manufacture"

  has_one :inventory_product_info, foreign_key: :manufacture_id

  validates_presence_of :manufacture

  def is_used_anywhere?
    inventory_product_info.present?
  end

end

class InventoryUnit < ActiveRecord::Base
  self.table_name = "mst_inv_unit"

  has_many :inventory_products, foreign_key: :unit_id
  has_many :inventory_product_infos, foreign_key: :secondary_unit_id
  has_many :inventory_po_item, foreign_key: :unit_id

  validates_presence_of [:unit, :description]

  def is_used_anywhere?
    inventory_products.any? or inventory_product_infos.any?
  end

end

class InventoryBatch < ActiveRecord::Base
  self.table_name = "inv_inventory_batch"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  has_many :grn_batches
  has_many :grn_items, through: :grn_batches

  has_many :inventory_serial_items, foreign_key: :batch_id

  has_many :inventory_batch_warranties, foreign_key: :batch_id
  accepts_nested_attributes_for :inventory_batch_warranties, allow_destroy: true
  has_many :inventory_warranties, through: :inventory_batch_warranties

  belongs_to :inventory
  belongs_to :inventory_product, foreign_key: :product_id

  validates_presence_of [:inventory_id, :product_id, :created_by, :lot_no, :batch_no]

  mapping do
    Grn
    indexes :inventory_product, type: "nested", include_in_parent: true
    indexes :inventory, type: "nested", include_in_parent: true
    indexes :grn_batches, type: "nested", include_in_parent: true
  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
    end
  end

  def to_indexed_json
    Inventory
    Grn
    to_json(
      only: [:id, :lot_no, :batch_no, :product_id, :remarks, :manufatured_date, :expiry_date, :created_at, :remarks],
      methods: [:batch_stock_cost],
      include: {
        inventory_product: {
          only: [:id, :description, :model_no, :product_no, :spare_part_no, :created_at],
          methods: [:category3_id, :category2_id, :category1_id, :generated_item_code],
        },
        inventory: {
          only: [:store_id, :damage_quantity, :available_quantity, :grn_item_id]
        },
        grn_batches: {
          only: [:remaining_quantity, :damage_quantity],
          include: {
            grn_item: {
              only: [:current_unit_cost, :remaining_quantity],
              include: {
                currency: {
                  only: [:currency],
                },
                grn: {
                  only: [:created_at, :store_id],
                  methods: [:grn_no_format],
                },
              },
            },
          },
        },
      },
    )

  end

  def batch_stock_cost
    grn_batches.to_a.sum{|b| b.remaining_quantity * b.grn_item.current_unit_cost }
  end

  after_save do |inventory_batch|
    [:inventory_product].each do |parent|
      puts "***********888"
      puts "indexing product"
      puts "***********888"
      inventory_batch.send(parent).update_index

    end

  end

end

class InventorySerialItem < ActiveRecord::Base
  self.table_name = "inv_inventory_serial_item"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :inventory_batch, foreign_key: :batch_id
  belongs_to :inventory
  belongs_to :product_condition
  belongs_to :inventory_serial_item_status, foreign_key: :inv_status_id
  belongs_to :inventory_product, foreign_key: :product_id

  has_many :inventory_serial_parts, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_parts, allow_destroy: true

  has_many :grn_serial_items, foreign_key: :serial_item_id
  accepts_nested_attributes_for :grn_serial_items, allow_destroy: true
  has_many :grn_items, through: :grn_serial_items

  has_many :remaining_grn_items, -> { where("inv_grn_serial_item.remaining= ?", true)}, through: :grn_serial_items, source: :grn_item

  has_many :inventory_serial_items_additional_costs, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_items_additional_costs, allow_destroy: true

  has_many :inventory_serial_warranties, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_warranties, allow_destroy: :true
  has_many :inventory_warranties, through: :inventory_serial_warranties

  has_many :grn_serial_parts, foreign_key: :serial_item_id
  has_many :grn_item_for_parts, through: :grn_serial_parts, source: :grn_item

  validates_presence_of [:inventory_id, :product_id, :serial_no, :product_condition_id, :inv_status_id, :created_by]

  mapping do
    Grn
    indexes :inventory_product, type: "nested", include_in_parent: true
    indexes :product_condition, type: "nested", include_in_parent: true
    # indexes :grn_items, type: "nested", include_in_parent: true
    indexes :inventory_serial_item_status, type: "nested", include_in_parent: true
    indexes :inventory, type: "nested", include_in_parent: true
    indexes :inventory_serial_items_additional_costs, type: "nested", include_in_parent: true
    indexes :remaining_grn_items, type: "nested", include_in_parent: true do
      indexes :current_unit_cost, type: "double"
    end

    # indexes "remaining_grn_items.current_unit_cost", type: "double"
  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          # must { term :store_id, params[:store_id] } if params[:store_id].present?
          # puts params[:store_id]
        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
      # filter :range, published_at: { lte: Time.zone.now}

      # aggs do
      #   intraday_return do
      #     sum { field "remaining_grn_items.current_unit_cost"}
      #   end
      # end
      # sum { field "remaining_grn_items.current_unit_cost"}

      # raise to_curl
    end
  end

  def to_indexed_json
    Inventory
    Grn
    to_json(
      only: [:serial_no, :ct_no, :damaged, :used, :scavenge, :repaired, :reserved, :parts_not_completed, :manufatured_date, :expiry_date, :remarks, :created_at],
      methods: [:generated_serial_no],
      include: {
        inventory_product: {
          only: [:id, :description, :model_no, :product_no, :spare_part_no, :created_at],
          methods: [:category3_id, :category2_id, :category1_id, :generated_item_code],
        },
        product_condition: {
          only: [:condition],
        },
        inventory_serial_item_status: {
          only: [:name],
        },
        inventory: {
          only: [:store_id],
          methods: [:store_name],
        },
        inventory_serial_items_additional_costs: {
          only: [:id, :serial_item_id, :cost],
        },
        remaining_grn_items: {
          only: [:current_unit_cost, :remaining_quantity, :created_at],
          include: {
            grn: {
              methods: [:grn_no_format],
              only: [:grn_no, :created_at, :store_id],
            },
            currency: {
              only: [:code, :symbol, :currency]
            }
          },
        },
      },
    )

  end

  after_save do |inventory_serial_item|
    inventory_serial_item.update_index

    [:inventory_product].each do |parent|
      parent.to_s.classify.constantize.find(inventory_serial_item.send(parent).id).update_index
    end

  end

  def generated_serial_no
    serial_no.to_s.rjust(5, INOCRM_CONFIG["inventory_serial_no_format"])
  end

end

class InventorySerialPart < ActiveRecord::Base
  self.table_name = "inv_inventory_serial_part"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_item, allow_destroy: true

  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :inventory_serial_item_status, foreign_key: :inv_status_id
  belongs_to :product_condition

  has_many :gin_sources, foreign_key: :serial_part_id

  has_many :inventory_serial_part_additional_costs, foreign_key: :serial_part_id
  accepts_nested_attributes_for :inventory_serial_part_additional_costs, allow_destroy: true

  has_many :inventory_serial_part_warranties, foreign_key: :serial_part_id
  accepts_nested_attributes_for :inventory_serial_part_warranties, allow_destroy: true
  has_many :inventory_warranties, through: :inventory_serial_part_warranties
  has_many :damages

  has_many :grn_serial_parts, foreign_key: :inv_serial_part_id
  accepts_nested_attributes_for :grn_serial_parts, allow_destroy: true
  has_many :grn_items, through: :grn_serial_parts

end

class ProductCondition < ActiveRecord::Base
  self.table_name = "mst_inv_product_condition"

  has_many :inventory_serial_items
  has_many :inventory_serial_parts

  validates_presence_of :condition

  def is_used_anywhere?
    inventory_serial_items.any? or inventory_serial_parts.any?
  end

end

class InventorySerialItemStatus < ActiveRecord::Base
  self.table_name = "mst_inv_serial_item_status"

  has_many :inventory_serial_items, foreign_key: :inv_status_id
  has_many :inventory_serial_parts, foreign_key: :inv_status_id
end

class InventorySerialPartAdditionalCost < ActiveRecord::Base
  self.table_name = "inv_serial_part_additional_cost"

  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :created_by_user, foreign_key: :created_by, class_name: "User"
  belongs_to :currency
end

class InventorySerialItemsAdditionalCost < ActiveRecord::Base
  self.table_name = "inv_serial_additional_cost"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  belongs_to :created_by_user, foreign_key: :created_by, class_name: "User"
  belongs_to :currency, foreign_key: :currency_id

  before_save do |additional_cost|
    if additional_cost.cost_changed?
      puts "***************8"
      puts "cost changed"
      puts "***************8"
      Rails.cache.delete([:stock_cost, additional_cost.inventory_serial_item.product_id, additional_cost.inventory_serial_item.inventory_id ])

    end

  end

end

class InventorySerialPartWarranty < ActiveRecord::Base
  self.table_name = "inv_serial_part_warranty"

  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :inventory_warranty, foreign_key: :warranty_id
  accepts_nested_attributes_for :inventory_warranty, allow_destroy: true
end

class InventorySerialWarranty < ActiveRecord::Base
  self.table_name = "inv_serial_warranty"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_item, :allow_destroy => true

  belongs_to :inventory_warranty, foreign_key: :warranty_id
  accepts_nested_attributes_for :inventory_warranty, :allow_destroy => true
end

class InventoryBatchWarranty < ActiveRecord::Base
  self.table_name = "inv_batch_warranty"

  belongs_to :inventory_batch, foreign_key: :batch_id
  belongs_to :inventory_warranty, foreign_key: :warranty_id
  accepts_nested_attributes_for :inventory_warranty, allow_destroy: true
end

class InventoryWarranty < ActiveRecord::Base
  self.table_name = "inv_warranty"

  has_many :inventory_serial_part_warranties, foreign_key: :warranty_id
  has_many :inventory_serial_parts, through: :inventory_serial_part_warranties


  has_many :inventory_serial_warranties, foreign_key: :warranty_id
  has_many :inventory_warranties_for_serials, through: :inventory_batch_warranties, source: :inventory_warranty

  has_many :inventory_batch_warranties, foreign_key: :warranty_id
  has_many :inventory_warranties_for_batches, through: :inventory_batch_warranties, source: :inventory_warranty

  belongs_to :inventory_warranty_type, foreign_key: :warranty_type_id

  validates_presence_of [:warranty_type_id, :start_at, :end_at, :created_by]

end

class InventoryWarrantyType < ActiveRecord::Base
  self.table_name = "mst_inv_warranty_type"

  has_many :inventory_warranties, foreign_key: :warranty_type_id

end

class InventoryReason < ActiveRecord::Base
  self.table_name = "mst_inv_reason"

  has_many :damages, foreign_key: :damage_reason_id

  def is_used_anywhere?
    Damage
    damages.any?
  end

end

class InventoryRack < ActiveRecord::Base
  self.table_name = "mst_inv_rack"

  has_many :inventory_shelfs, foreign_key: :rack_id
  accepts_nested_attributes_for :inventory_shelfs, allow_destroy: true
  has_many :inventory_bins, through: :inventory_shelfs

  belongs_to :organization, foreign_key: :location_id
  belongs_to :created_user, foreign_key: :created_by
  belongs_to :updated_user, foreign_key: :updated_by

  validates_presence_of [:description, :location_id]


  def is_used_anywhere?
    inventory_shelfs.any?
  end

end

class InventoryShelf < ActiveRecord::Base
  self.table_name = "mst_inv_shelf"

  has_many :inventory_bins, foreign_key: :shelf_id
  accepts_nested_attributes_for :inventory_bins, allow_destroy: true
  has_many :inventories, through: :inventory_bins

  belongs_to :inventory_rack, foreign_key: :rack_id
  belongs_to :created_user, foreign_key: :created_by
  belongs_to :updated_user, foreign_key: :updated_by

  def is_used_anywhere?
    inventory_bins.any?
  end
end

class InventoryBin < ActiveRecord::Base
  self.table_name = "mst_inv_bin"

  belongs_to :inventory_shelf, foreign_key: :shelf_id
  belongs_to :created_user, foreign_key: :created_by
  belongs_to :updated_user, foreign_key: :updated_by
  has_many :inventories, foreign_key: :bin_id

  def is_used_anywhere?
    inventories.any?
  end

end

class InventoryDisposalMethod < ActiveRecord::Base
  self.table_name = "mst_inv_disposal_method"

  belongs_to :user, foreign_key: :created_by
  belongs_to :user, foreign_key: :updated_by
  has_many :inventory_damages, foreign_key: :disposal_method_id
  has_many :inventory_requests, foreign_key: :disposal_method_id

  validates :disposal_method, presence: true, uniqueness: true

  def is_used_anywhere?
    # inventory_damages.any? or inventory_requests.any? or user.present?
    inventory_damages.any?
  end

end

class InventoryDamage < ActiveRecord::Base
  self.table_name = "inv_damage"
  belongs_to :inventory_disposal_method
end

class InventoryRequest < ActiveRecord::Base
  self.table_name = "inv_disposal_request"
  belongs_to :inventory_disposal_method
end

class InventoryPo < ActiveRecord::Base
  self.table_name = "inv_po"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :supplier, class_name: "Organization", foreign_key: :supplier_id
  belongs_to :store, class_name: "Organization", foreign_key: :store_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by
  belongs_to :approved_by_user, class_name: "User", foreign_key: :approved_by
  belongs_to :currency
  belongs_to :payment_term, foreign_key: :payment_term_id

  has_many :inventory_po_items, foreign_key: :po_id
  accepts_nested_attributes_for :inventory_po_items, allow_destroy: true

  validates_presence_of [:supplier_id, :store_id, :po_no, :discount_amount]

  mapping do
    indexes :supplier, type: "nested", include_in_parent: true
    indexes :store, type: "nested", include_in_parent: true
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :formated_created_at, lte: params[:po_date_to].to_date } if params[:po_date_to].present?
          must { range :formated_created_at, gte: params[:po_date_from].to_date } if params[:po_date_from].present?
          # must { term :author_id, params[:author_id] } if params[:author_id].present?
        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
      # highlight customer_name: {number_of_fragments: 0}, ticket_status_name: {number_of_fragments: 0}, :options => { :tag => '<strong class="highlight">' } if params[:query].present?
      # filter :range, published_at: { lte: Time.zone.now}
      # raise to_curl
    end
  end

  def to_indexed_json
    Warranty
    to_json(
      only: [:created_at, :id, :delivery_date, :closed],
      methods: [:store_name, :formated_po_no, :formated_created_at, :created_by_user_full_name],
      include: {
        store: {
          only: [:id, :name],
        },
        supplier: {
          only: [:id, :name],
        },
      },
    )

  end

  def store_name
    store.name
  end

  def formated_po_no
    po_no.to_s.rjust(5, INOCRM_CONFIG["inventory_po_no_format"])
  end

  def created_by_user_full_name
    created_by_user.full_name
  end

  def formated_created_at
    created_at.to_date.strftime(INOCRM_CONFIG["short_date_format"])
  end
end

class InventoryPoItem < ActiveRecord::Base
  self.table_name = "inv_po_item"

  belongs_to :inventory_po, foreign_key: :po_id
  belongs_to :inventory_prn_item, foreign_key: :prn_item_id
  belongs_to :inventory_unit, foreign_key: :unit_id

  has_many :inventory_po_item_taxes, foreign_key: :po_item_id
  accepts_nested_attributes_for :inventory_po_item_taxes, allow_destroy: true

  has_many :grn_items, foreign_key: :po_item_id
  accepts_nested_attributes_for :grn_items, allow_destroy: true
  has_many :grns, through: :grn_items

  has_many :dyna_columns, as: :resourceable, autosave: true

  [:temp_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save# if data.persisted?
    end
  end
end

class InventoryPoItemTax < ActiveRecord::Base
  self.table_name = "inv_po_item_tax"

  belongs_to :inventory_po_item, foreign_key: :po_item_id
  belongs_to :tax, foreign_key: :tax_id
end

class InventoryPrn < ActiveRecord::Base
  self.table_name = "inv_prn"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :store, class_name: "Organization", foreign_key: :store_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :inventory_prn_items, foreign_key: :prn_id
  accepts_nested_attributes_for :inventory_prn_items, allow_destroy: true
  has_many :inventory_products, through: :inventory_prn_items


  mapping do
    indexes :products, type: "nested", include_in_parent: true
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :required_at, lte: params[:range_to].to_date } if params[:range_to].present?
          must { range :required_at, gte: params[:range_from].to_date } if params[:range_from].present?
          # must { term :author_id, params[:author_id] } if params[:author_id].present?
        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
      # highlight customer_name: {number_of_fragments: 0}, ticket_status_name: {number_of_fragments: 0}, :options => { :tag => '<strong class="highlight">' } if params[:query].present?
      # filter :range, published_at: { lte: Time.zone.now}
      # raise to_curl
    end
  end

  def to_indexed_json
    Warranty
    to_json(
      only: [:created_at, :prn_no, :store_id, :required_at, :remarks, :closed],
      methods: [:store_name, :formated_prn_no, :created_by_user_full_name],
    )

  end

  def store_name
    store.name
  end

  def formated_prn_no
    prn_no.to_s.rjust(5, INOCRM_CONFIG["inventory_prn_no_format"])
  end

  def created_by_user_full_name
    created_by_user.full_name
  end
end

class InventoryPrnItem < ActiveRecord::Base
  self.table_name = "inv_prn_item"

  belongs_to :inventory_prn, foreign_key: :prn_id
  belongs_to :inventory_product, foreign_key: :product_id

  has_many :inventory_po_items, foreign_key: :prn_item_id

  validates_presence_of :product_id
end