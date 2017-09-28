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
  has_many :prn_srn_items, through: :srn_items

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
        params[:query] = params[:query].split(" AND ").map{|q| q.starts_with?("formatted_srn_no") ? "("+q+" OR #{q.gsub('formatted_srn_no', 'srn_no')})" : q }.join(" AND ")
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
    Role
    to_json(
      only: [:id, :remarks, :created_at, :created_by, :closed, :store_id, :requested_module_id, :srn_no, :so_no, :so_customer_id],
      methods: [:store_name, :formatted_srn_no, :created_by_user_full_name, :formated_created_at, :inventories_available, :so_customer_name],
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

  def so_customer_name
    so_customer.try(:name)
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

  before_create :assign_srn_no
  def assign_srn_no
    Organization

    self.srn_no = CompanyConfig.first.next_sup_last_srn_no
  end

  def requested_quantity
    srn_items.sum(:quantity)
  end

  before_save do |srn|
    if srn.persisted? and srn.remarks_changed? and srn.remarks.present?
      srn_remarks = "#{srn.remarks} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(srn.current_user_id).try(:full_name)}</span><br/>#{srn.remarks_was}"
    elsif srn.new_record?
      srn_remarks = srn.remarks  
    else
      srn_remarks = srn.remarks_was
    end
    srn.remarks = srn_remarks
  end

  has_many :dyna_columns, as: :resourceable, autosave: true

  [:current_user_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save
    end
  end
end

class SrnItem < ActiveRecord::Base
  self.table_name = "inv_srn_item"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :srn
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :main_inventory_product, class_name: "InventoryProduct", foreign_key: :main_product_id
  belongs_to :issue_terminated_reason, class_name: "InventoryReason"
  belongs_to :issue_terminated_by_user, class_name: "User", foreign_key: :issue_terminated_by

  has_many :ticket_spare_part_stores, foreign_key: :inv_srn_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_item_id
  has_many :gin_items
  has_many :grn_items
  has_many :gins, through: :gin_items

  has_many :prn_srn_items, foreign_key: :srn_item_id
  has_many :inventory_prn_items, through: :prn_srn_items

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
      if params[:query]
        params[:query] = params[:query].split(" AND ").map{|q| q.starts_with?("srn.formatted_srn_no") ? "("+q+" OR #{q.gsub('srn.formatted_srn_no', 'srn.srn_no')})" : q }.join(" AND ")
        params[:query].gsub!("/", "\\/")

      end
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
        end
      end
      sort { by "srn.id", {order: "desc", ignore_unmapped: true} }
    end
  end

  after_create :update_index_inventory_product
  def update_index_inventory_product
    Inventory

    inventory_product.update_index
  end

  def inventory
    Inventory.where(product_id: product_id, store_id: srn.store_id ).first
  end

  def balance_to_be_issued
    quantity.to_f - gin_items.sum(:issued_quantity)
  end


  mapping do
    indexes :inventory_product, type: "nested", include_in_parent: true
    indexes :srn, type: "nested", include_in_parent: true
    indexes :inventory_unit, type: "nested", include_in_parent: true
    indexes :gin_items, type: "nested", include_in_parent: true
  end

  def to_indexed_json
    Srn
    Inventory
    Gin
    to_json(
      only: [:id, :closed, :quantity, :created_at],
      methods: [:srn_id, :inventory, :balance_to_be_issued],
      include: {
        inventory_product: {
          only: [:id, :description, :model_no, :product_no, :spare_part_no, :created_at],
          methods: [:category3_id, :category2_id, :category1_id, :category1_name, :category2_name,:category3_name, :generated_item_code],
          include: {
            inventory_unit: {
              only: [:unit],
            },
          },
        },
        srn: {
          only: [:id, :srn_no, :store_id, :so_no, :so_customer_id],
          methods: [:formatted_srn_no, :created_at],
        },
        gin_items: {
          only: [:id],
        },
        inventory_prn_items: {
          only: [:id],
          methods: [:formated_prn_no],
          include: {
            inventory_prn: {
              only: [:id]
            }
          }
        }
      },
    )

  end
end