class Grn < ActiveRecord::Base
  self.table_name = "inv_grn"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  # mapping do
  #   indexes :tickets, type: "nested", include_in_parent: true
  # end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          # must { term :store_id, params[:store_id] } if params[:store_id].present?
          must { range :formated_created_at, lte: params[:range_to].to_date } if params[:range_to].present?
          must { range :formated_created_at, gte: params[:range_from].to_date } if params[:range_from].present?
          # filter :range, published_at: { lte: Time.zone.now}
          # raise to_curl
        end
      end
      sort { by :grn_no, {order: "desc", ignore_unmapped: true} }
    end
  end

  def to_indexed_json
    to_json(
      only: [:id, :store_id, :grn_no, :created_by, :remarks, :po_no, :supplier_id, :created_at, :created_by_user],
      methods: [:store_name, :supplier_name, :grn_no_format, :formated_created_at, :created_by_from_user],
    )

  end

  def grn_no_format
    grn_no.to_s.rjust(5, INOCRM_CONFIG["inventory_grn_no_format"])
  end

  def store_name
    store.name
  end

  def supplier_name
    supplier.try(:name)
  end

  def formated_created_at
    created_at.to_date.strftime(INOCRM_CONFIG["short_date_format"])
  end

  def created_by_from_user
    created_by_user.full_name
  end

  belongs_to :store, class_name: "Organization"
  belongs_to :srn
  belongs_to :inventory_po, foreign_key: :po_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by
  belongs_to :supplier, class_name: "Organization" #, -> { where(id: 2) }#, foreign_key: :po_id

  has_many :grn_items

end

class GrnItem < ActiveRecord::Base
  self.table_name = "inv_grn_item"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :srn_item
  belongs_to :grn
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :inventory_po_item, foreign_key: :po_item_id
  belongs_to :currency

  has_many :grn_batches
  accepts_nested_attributes_for :grn_batches, allow_destroy: true
  has_many :inventory_batches, through: :grn_batches
  accepts_nested_attributes_for :inventory_batches, allow_destroy: true

  has_many :grn_serial_items, foreign_key: :grn_item_id
  accepts_nested_attributes_for :grn_serial_items, allow_destroy: true
  has_many :inventory_serial_items, through: :grn_serial_items

  has_many :grn_serial_parts, foreign_key: :grn_item_id
  # has_many :inventory_serial_item_for_grn_serial_parts, through: :grn_serial_parts
  # has_many :inventory_serial_parts, through: :grn_serial_parts
  scope :only_grn_items, ->(id) { joins(:grn_serial_items, :grn_batches).where.not(inv_grn_batch: { grn_item_id: id }, inv_grn_serial_item: { grn_item_id: id })}

  has_many :damages
  accepts_nested_attributes_for :damages, allow_destroy: true

  has_many :gin_sources
  has_many :gin_serial_parts
  has_many :grn_item_current_unit_cost_histories
  accepts_nested_attributes_for :grn_item_current_unit_cost_histories, allow_destroy: true

  after_save :update_relation_index

  def self.only_grn_items1
    select{|grn_item| grn_item.grn_serial_items.blank? and grn_item.grn_batches.blank? and grn_item.grn_serial_parts.blank? }
  end

  def any_remaining_serial_item
    grn_serial_items.any? { |s| s.remaining }
  end

  def update_relation_index
    [:inventory_serial_items].each do |children|
      self.send(children).each do |child|
        # child.update_index
        # parent.to_s.classify.constantize.find(self.send(parent).id).update_index
        children.to_s.classify.constantize.find(child.id).update_index

      end
    end

    # [:grn].each do |parent|
    #   self.send(parent).update_index
    # end
  end

  before_save do |grn_item|
    if grn_item.persisted? and grn_item.remarks_changed? and grn_item.remarks.present?
      grn_item_remarks = "#{grn_item.remarks} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(grn_item.current_user_id).email}</span><br/>#{grn_item.remarks_was}"
    elsif grn_item.new_record?
      grn_item_remarks = grn_item.remarks  
    else
      grn_item_remarks = grn_item.remarks_was
    end
    grn_item.remarks = grn_item_remarks
  end

  has_many :dyna_columns, as: :resourceable, autosave: true

  [:flagged_as, :current_user_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save# if data.persisted?
    end
  end

  validates_presence_of :recieved_quantity
  # validates_presence_of [:unit_cost, :current_unit_cost, :currency_id, :recieved_quantity, :remaining_quantity, :grn_id], on: :create
  # validates_presence_of :unit_cost, on: :create

  mapping do
    indexes :inventory_product, type: "nested", include_in_parent: true
    indexes :inventory_serial_items, type: "nested", include_in_parent: true
    indexes :grn, type: "nested", include_in_parent: true
    indexes :grn_item_current_unit_cost_histories, type: "nested", include_in_parent: true
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
      sort { by :created_at, "desc" }
      # filter :range, published_at: { lte: Time.zone.now}
      # raise to_curl
    end
  end

  def to_indexed_json
    Inventory
    to_json(
      only: [:serial_no, :ct_no, :created_at],
      include: {
        inventory_product: {
          only: [:id, :description, :model_no, :product_no, :spare_part_no, :created_at],
          methods: [:category3_id, :category2_id, :category1_id, :generated_item_code],
        },
        inventory_serial_items: {
          only: [:serial_no, :ct_no, :damaged, :used, :scavenge, :repaired, :reserved, :parts_not_completed, :manufatured_date, :expiry_date, :remarks],
          include: {
            product_condition: {
              only: [:name]
            },
            inventory_serial_item_status: {
              only: [:name]
            }
          }
        },
        grn: {
          only: [:grn_no, :created_at, :store_id],
          methods: [:grn_no_format]
        },
        grn_item_current_unit_cost_histories: {
          only: [:id, :created_at, :current_unit_cost, :created_by],
        },
      }
    )

  end

end

class GrnBatch < ActiveRecord::Base
  self.table_name = "inv_grn_batch"

  belongs_to :grn_item
  belongs_to :inventory_batch
  accepts_nested_attributes_for :inventory_batch, allow_destroy: true

  has_many :gin_sources
  has_many :damages

  validates_presence_of :recieved_quantity

  def grn_current_unit_cost
    grn_item.current_unit_cost
  end

end

class GrnSerialItem < ActiveRecord::Base
  self.table_name = "inv_grn_serial_item"

  belongs_to :grn_item, foreign_key: :grn_item_id
  accepts_nested_attributes_for :grn_item, allow_destroy: true
  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_item, allow_destroy: true

  has_many :gin_sources#, foreign_key: :gin_item_id
  has_many :damages

  def self.active_serial_items
    where(remaining: true)
  end

end

class GrnSerialPart < ActiveRecord::Base
  self.table_name = "inv_grn_serial_part"

  belongs_to :grn_item
  accepts_nested_attributes_for :grn_item, allow_destroy: true
  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  belongs_to :inventory_serial_part, foreign_key: :inv_serial_part_id

  has_many :gin_sources, foreign_key: :grn_serial_part_id

  def self.active_serial_parts
    where(remaining: true)
  end

end

class GrnItemCurrentUnitCostHistory < ActiveRecord::Base
  self.table_name = "inv_grn_item_current_unit_cost_history"

  belongs_to :grn_item
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by
end