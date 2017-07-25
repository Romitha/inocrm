class Srn < ActiveRecord::Base
  self.table_name = "inv_srn"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :store, type: "nested", include_in_parent: true
    indexes :srn_items, type: "nested", include_in_parent: true
    indexes :gins, type: "nested", include_in_parent: true
  end

  belongs_to :store, -> { where(type_id: 4) }, class_name: "Organization"
  belongs_to :requested_location, class_name: "Organization"
  belongs_to :so_customer, class_name: "Organization"
  belongs_to :requested_module, class_name: "BpmModule", foreign_key: :requested_module_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :srn_items
  accepts_nested_attributes_for :srn_items, allow_destroy: true
  has_many :inventory_products, through: :srn_items
  has_many :gins
  accepts_nested_attributes_for :gins, allow_destroy: true
  has_many :ticket_spare_part_stores, foreign_key: :inv_srn_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_id

  def inventories
    Inventory.where(product_id: srn_items.map { |s| s.product_id  }, store_id: store_id )

  end

  def inventories_available
    inventories.to_a.sum{|i| i.available_quantity.to_f } > 0 ? "Yes" : "No"
  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: 10) do
      if params[:query]
        params[:query] = params[:query].split(" AND ").map{|q| q.starts_with?("formatted_srn_no") ? q+" OR #{q.gsub('formatted_srn_no', 'srn_no')}" : q }.join(" AND ")
        params[:query].gsub!("/", "\\/")

      end
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :created_at, lte: params[:srn_date_to].to_date.end_of_day } if params[:srn_date_to].present?
          must { range :created_at, gte: params[:srn_date_from].to_date.beginning_of_day } if params[:srn_date_from].present?

        end
      end

      sort { by :created_at, {order: "desc", ignore_unmapped: true} }

    end
  end

  def to_indexed_json
    to_json(
      only: [:id, :remarks, :created_at, :created_by, :closed, :store_id, :requested_module_id, :srn_no, :so_no],
      methods: [:store_name, :formatted_srn_no, :created_by_user_full_name, :formated_created_at, :inventories_available],
      include: {
        store: {
          only: [:id, :name],
        },
        requested_module: {
          only: [:id, :name],
        },
        srn_items: {
          only: [:id, :closed, :quantity, :spare_part ],
          include: {
            inventory_product: {
              only: [:product_no, :model_no, :serial_no, :description],
              methods: [:generated_serial_no, :generated_item_code],
            },
          },
        },
        gins: {
          only: [:id],
        },
      },
    )

  end

  def store_name
    store.name
  end

  def formatted_srn_no
    srn_no.to_s.rjust(6, INOCRM_CONFIG["inventory_srn_no_format"])
  end

  def formated_created_at
    created_at.to_date.strftime(INOCRM_CONFIG["short_date_format"])
  end

  def created_by_user_full_name
    created_by_user.full_name
  end

  def assign_srn_no
    Organization

    self.srn_no = CompanyConfig.first.next_sup_last_srn_no
  end

  # def update_index_inventory_product
  #   inventory_products.each{ |inventory_product| inventory_product.update_index }
  # end

  before_create :assign_srn_no
  # after_create :update_index_inventory_product

end

# class Srn < ActiveRecord::Base
#   self.table_name = "inv_srn"

#   belongs_to :store, -> { where(type_id: 4) }, class_name: "Organization"
#   belongs_to :requested_location, class_name: "Organization"
#   belongs_to :so_customer, class_name: "Organization"
#   belongs_to :requested_module, class_name: "BpmModule", foreign_key: :requested_module_id
#   belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

#   has_many :srn_items
#   accepts_nested_attributes_for :srn_items, allow_destroy: true
#   has_many :inventory_products, through: :srn_items
#   has_many :gins
#   accepts_nested_attributes_for :gins, allow_destroy: true
#   has_many :ticket_spare_part_stores, foreign_key: :inv_srn_id
#   has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_id

#   def formatted_srn_no
#     srn_no.to_s.rjust(6, INOCRM_CONFIG["inventory_srn_no_format"])
#   end
# end

class SrnItem < ActiveRecord::Base
  self.table_name = "inv_srn_item"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :srn
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :main_inventory_product, class_name: "InventoryProduct", foreign_key: :main_product_id

  has_many :ticket_spare_part_stores, foreign_key: :inv_srn_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_item_id
  has_many :gin_items
  has_many :grn_items
  has_many :gins, through: :gin_items

  validates :quantity, :numericality => {:greater_than => 0}

  def formatted_srn_no
    srn.srn_no.to_s.rjust(6, INOCRM_CONFIG["inventory_srn_no_format"])
  end

  def srn_id
    srn.id
  end

  def store_id
    srn.store.id
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

  def update_index_inventory_product
    Inventory

    inventory_product.update_index
  end

  after_create :update_index_inventory_product

  mapping do
    indexes :inventory_product, type: "nested", include_in_parent: true
    indexes :srn, type: "nested", include_in_parent: true
    indexes :inventory_unit, type: "nested", include_in_parent: true
  end

  def to_indexed_json
    Srn
    Inventory
    to_json(
      only: [:id],
      methods: [:srn_id],
      include: {
        inventory_product: {
          only: [:id, :description, :model_no, :product_no, :spare_part_no, :created_at, :inventories],
          methods: [:category3_id, :category2_id, :category1_id, :category1_name, :category2_name,:category3_name, :generated_item_code],
          include: {
            inventory_unit: {
              only: [:unit],
            },
          },
        },
        srn: {
          only: [:id],
          methods: [:formatted_srn_no],
        },
      },
    )


  end
end