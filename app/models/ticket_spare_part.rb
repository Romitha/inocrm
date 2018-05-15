class TicketSparePart < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part"

  belongs_to :ticket
  accepts_nested_attributes_for :ticket, allow_destroy: true

  belongs_to :ticket_fsr, foreign_key: :fsr_id
  belongs_to :spare_part_status_action, foreign_key: :status_action_id
  belongs_to :spare_part_status_use, foreign_key: :status_use_id

  has_many :request_spare_parts
  accepts_nested_attributes_for :request_spare_parts, allow_destroy: true

  has_many :ticket_spare_part_status_actions, foreign_key: :spare_part_id

  has_one :ticket_spare_part_manufacture, foreign_key: :spare_part_id
  accepts_nested_attributes_for :ticket_spare_part_manufacture, allow_destroy: true
  has_many :ticket_spare_parts, through: :ticket_spare_part_manufacture

  has_one :ticket_spare_part_store, foreign_key: :spare_part_id
  accepts_nested_attributes_for :ticket_spare_part_store, allow_destroy: true

  # accepts_nested_attributes_for :return_parts_bundles, allow_destroy: true

  has_one :ticket_spare_part_non_stock, foreign_key: :spare_part_id
  accepts_nested_attributes_for :ticket_spare_part_non_stock, allow_destroy: true

  has_many :ticket_on_loan_spare_parts, foreign_key: :ref_spare_part_id
  accepts_nested_attributes_for :ticket_on_loan_spare_parts, allow_destroy: true

  belongs_to :unused_reason, -> { where(spare_part_unused: true) }, class_name: "Reason", foreign_key: :unused_reason_id

  belongs_to :part_terminated_reason, -> { where(terminate_spare_part: true) }, class_name: "Reason", foreign_key: :part_terminated_reason_id

  has_many :ticket_estimation_parts, foreign_key: :ticket_spare_part_id

  has_many :so_po_items, foreign_key: :ticket_spare_part_id


  validates_presence_of :spare_part_description

  belongs_to :engineer, class_name: "TicketEngineer", foreign_key: :engineer_id

  before_save do |ticket_spare_part|
   if ticket_spare_part.persisted? and ticket_spare_part.note_changed? and ticket_spare_part.note.present?
      ticket_spare_part_note = "#{ticket_spare_part.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket_spare_part.current_user_id).try(:full_name)}</span><br/>#{ticket_spare_part.note_was}"
    elsif ticket_spare_part.new_record?
      ticket_spare_part_note = ticket_spare_part.note
    else
      ticket_spare_part_note = ticket_spare_part.note_was
    end
    ticket_spare_part.note = ticket_spare_part_note
  end

  after_save :flush_cache
  def spare_part_brand_name
    ticket.products.first.try(:brand_name)
  end

  def spare_part_event_no
    ticket_spare_part_manufacture.try(:event_no)
  end

  def flush_cache
    Rails.cache.delete([self.ticket.id, :ticket_spare_parts])
  end

  def inventory_product
    (ticket_spare_part_store or ticket_spare_part_non_stock).try(:inventory_product)
  end

  def inventory_product_generated_serial_item
    inventory_product.try(:generated_item_code)
  end

  def ticket_status
    ticket.ticket_status.name
  end
  def ticket_serial_no
    ticket.ticket_product_serial_no
  end
  def engineer_name
    engineer.full_name
  end
  has_many :dyna_columns, as: :resourceable, autosave: true

  # has_many :invoices, foreign_key: "customer_id"

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

class SoPoItem < ActiveRecord::Base
  self.table_name = "spt_so_po_item"

  belongs_to :ticket_spare_part
  belongs_to :so_po
  belongs_to :ticket_spare_part_manufacture

  # validates_presence_of :amount
end

class SoPo < ActiveRecord::Base
  self.table_name = "spt_so_po"
  Product

  include Tire::Model::Search
  include Tire::Model::Callbacks

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
      sort { by :po_no, {order: "asc", ignore_unmapped: true} }
    end
  end

  def to_indexed_json
    to_json(
      only: [:id, :product_brand_id, :po_no, :created_by, :created_at, :so_no, :note, :amount, :currency_id],
      methods: [:po_no_format, :currency_type, :brand_of_product_name, :formated_created_at],
      include: {
        so_po_items: {
          only: [:id, :ticket_spare_part_id],
          include: {
            ticket_spare_part: {
              only: [:id, :ticket_id],
              include: {
                ticket: {
                  only: [:id, :ticket_no],
                  methods: [:support_ticket_no],
                },
              },
            },
          },
        },
      },
    )
  end

  def po_no_format
    po_no.to_s.rjust(5, INOCRM_CONFIG["inventory_po_no_format"])
  end

  def currency_type
    currency.code
  end

  def brand_of_product_name
    product_brand.try(:name)
  end

  def formated_created_at
    created_at.to_date.strftime(INOCRM_CONFIG["short_date_format"])
  end

  belongs_to :currency, foreign_key: :currency_id
  belongs_to :user, foreign_key: :created_by
  belongs_to :product_brand, foreign_key: :product_brand_id

  belongs_to :invoice

  has_many :so_po_items, foreign_key: :spt_so_po_id
  accepts_nested_attributes_for :so_po_items, allow_destroy: true
  validates :po_no, :po_date, :so_no, :amount, presence: true
  validates_uniqueness_of :po_no

end

class TicketSparePartStore < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_store"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :inventory_product, foreign_key: :inv_product_id
  belongs_to :ticket_estimation_part, foreign_key: :ticket_estimation_part_id
  belongs_to :store, -> { where(type_id: 4) }, class_name: "Organization", foreign_key: :store_id
  belongs_to :main_inventory_product, class_name: "InventoryProduct", foreign_key: :mst_inv_product_id
  belongs_to :return_part_damage_reason, class_name: "Reason"

  belongs_to :approved_store, class_name: "Organization", foreign_key: :approved_store_id
  belongs_to :approved_inventory_product, class_name: "InventoryProduct", foreign_key: :approved_inv_product_id
  belongs_to :approved_main_inventory_product, class_name: "InventoryProduct", foreign_key: :approved_main_inv_product_id

  belongs_to :gin, foreign_key: :inv_gin_id
  belongs_to :gin_item, foreign_key: :inv_gin_item_id

  belongs_to :srn, foreign_key: :inv_srn_id
  belongs_to :srn_item, foreign_key: :inv_srn_item_id

  belongs_to :srr, foreign_key: :inv_srr_id
  belongs_to :srr_item, foreign_key: :inv_srr_item_id
  belongs_to :store_requested_engineer, class_name: "User", foreign_key: :store_requested_by

  def ticket_no
    ticket_spare_part.ticket.support_ticket_no
  end
  def customer_name
    ticket_spare_part.ticket.customer_name
  end
  def ticket_status
    ticket_spare_part.ticket.ticket_status.name
  end
  def recived_eng_at
    ticket_spare_part.received_eng_by
  end  
  def create_support_srn(current_user_id, store_id, inventory_product_id, quantity, main_inventory_product_id=nil)

    srn = Srn.create(store_id: store_id, created_by: current_user_id, created_at: DateTime.now, requested_module_id: BpmModule.find_by_code("SPT").id, srn_no: CompanyConfig.first.increase_inv_last_srn_no)#inv_srn

    srn_item = srn.srn_items.create(product_id: inventory_product_id, quantity: quantity, returnable: false, spare_part: true, main_product_id: main_inventory_product_id)#inv_srn_item

    update inv_srn_id: srn.id, inv_srn_item_id: srn_item.id
    CompanyConfig.first.increase_inv_last_srn_no

  end

  def dynamic_inventry_product
    if ticket_spare_part.request_approved
      approved_inventory_product.try(:category1_name)
    else
      inventory_product.try(:category1_name)
    end
  end
end

class TicketFsr < ActiveRecord::Base
  self.table_name = "spt_ticket_fsr"

  belongs_to :ticket
  belongs_to :ticket_engineer, foreign_key: :engineer_id
  accepts_nested_attributes_for :ticket
  # validates_presence_of [:work_started_at, :work_finished_at, :hours_worked, :hours_worked, :down_time, :travel_hours, :engineer_time_travel, :engineer_time_on_site, :resolution, :completion_level]

  has_one :act_fsr, foreign_key: :fsr_id
  accepts_nested_attributes_for :act_fsr, allow_destroy: true

  has_many :ticket_spare_parts, foreign_key: :fsr_id
  has_many :ticket_fsr_support_engineers, foreign_key: :fsr_id
  accepts_nested_attributes_for :ticket_fsr_support_engineers, allow_destroy: true

  before_save do |ticket_fsr|
    if ticket_fsr.persisted? and ticket_fsr.remarks_changed? and ticket_fsr.remarks.present?
      ticket_fsr_remarks = "#{ticket_fsr.remarks} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket_fsr.current_user_id).try(:full_name)}</span><br/>#{ticket_fsr.remarks_was}"
    elsif ticket_fsr.new_record?
      ticket_fsr_remarks = ticket_fsr.remarks
    else
      ticket_fsr_remarks = ticket_fsr.remarks_was
    end
    ticket_fsr.remarks = ticket_fsr_remarks
  end

  has_many :dyna_columns, as: :resourceable, autosave: true

  # has_many :invoices, foreign_key: "customer_id"

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

class TicketDeliverUnit < ActiveRecord::Base
  self.table_name = "spt_ticket_deliver_unit"

  belongs_to :ticket

  belongs_to :organization, foreign_key: :deliver_to_id
  belongs_to :collected_by_user, class_name: "User", foreign_key: :collected_by

  has_many :deliver_units, foreign_key: :ticket_deliver_unit_id
  accepts_nested_attributes_for :deliver_units, allow_destroy: true

  has_many :dyna_columns, as: :resourceable, autosave: true

  belongs_to :user, foreign_key: :created_by

  before_save do |ticket_deliver_unit|
    if ticket_deliver_unit.persisted? and ticket_deliver_unit.note_changed? and ticket_deliver_unit.note.present?
      ticket_deliver_unit_note = "#{ticket_deliver_unit.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket_deliver_unit.current_user_id).try(:full_name)}</span><br/>#{ticket_deliver_unit.note_was}"
    elsif ticket_deliver_unit.new_record?
      ticket_deliver_unit_note = ticket_deliver_unit.note  
    else
      ticket_deliver_unit_note = ticket_deliver_unit.note_was
    end
    ticket_deliver_unit.note = ticket_deliver_unit_note
  end

  [:current_user_id].each do |dyna_method|
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

class SparePartDescription < ActiveRecord::Base
  self.table_name = "mst_spt_spare_part_description"
  validates :description, presence: true, uniqueness: true

  scope :active_spare_part_descriptions, -> { where(active: true).order(created_at: :desc) }
end

class TicketSparePartManufacture < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_manufacture"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :ticket_spare_part, type: "nested", include_in_parent: true
    indexes :ticket, type: "nested", include_in_parent: true
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: (params[:per_page] || 1000)) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          # must { range :published_at, lte: Time.zone.now }
          # must { term :author_id, params[:author_id] } if params[:author_id].present?
        end
      end
      sort { by :action_at, "desc" } if params[:query].blank?
    end
  end

  def to_indexed_json
    Ticket
    TicketSparePart
    TaskAction
    to_json(
      only: [:id, :spare_part_id, :event_no, :order_no, :collect_pending_manufacture, :order_pending, :updated_at],
      include: {
        ticket_spare_part:{
          only: [:id, :spare_part_no, :spare_part_description, :request_from],
          include: {
            ticket: {
              only: [:id],
              methods:[:support_ticket_no],
              include: {
                user_ticket_actions: {
                  only: [:id, :action_id],
                  methods: [:formatted_action_date, :action_by_name, :action_engineer_by_name],
                },
                reason: {
                  only: [:id, :reason],
                },
              },
            },
          },
        },
      },
    )

  end

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :return_parts_bundle
  belongs_to :manufacture_currency, class_name: "Currency", foreign_key: :manufacture_currency_id

  has_many :so_po_items, foreign_key: :ticket_spare_part_item_id

end

class SparePartStatusAction < ActiveRecord::Base
  self.table_name = "mst_spt_spare_part_status_action"

  has_many :ticket_spare_parts, foreign_key: :status_action_id
  has_many :ticket_spare_part_status_actions, foreign_key: :status_id
  has_many :ticket_on_loan_spare_part_status_actions, foreign_key: :status_id

end

class SparePartStatusUse < ActiveRecord::Base
  self.table_name = "mst_spt_spare_part_status_use"

  has_many :ticket_spare_parts, foreign_key: :status_use_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :status_use_id

  belongs_to :spare_part_status_action, foreign_key: :status_id
end

class TicketSparePartStatusAction < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_status_action"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :spare_part_status_action, foreign_key: :status_id
end

class TicketOnLoanSparePart < ActiveRecord::Base
  self.table_name = "spt_ticket_on_loan_spare_part"

  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  mapping do
    indexes :inventory_product, type: "nested", include_in_parent: true
  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: (params[:per_page] || 10)) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :issued_at, gte: params[:issued_date_from].to_date.beginning_of_day } if params[:issued_date_from].present?
          must { range :issued_at, lte: params[:issued_date_to].to_date.end_of_day } if params[:issued_date_to].present?
        end
      end
      if params[:sort_by]
        sort { by :issued_at, {order: "ASC", ignore_unmapped: true} }
      end
    end
  end

  def to_indexed_json
    Product
    to_json(
      only: [:id, :store_id, :requested_by, :issued_by, :issued_at, :requested_quantity, :created_at, :updated_at],
      methods: [:store_name, :ticket_id, :ticket_no, :part_status, :rejected_reason, :formatted_issued_at, :issued_user, :requested_user],
      include: {
        inventory_product: {
          only: [:id, :description],
          methods: [:category3_id, :category2_id, :category1_id, :generated_item_code],
        },
        ticket_spare_part:{
          only: [:id, :spare_part_no, :spare_part_description],
        },
      },
    )
  end
  def issued_user
    issued_by_user.try(:full_name)
  end
  def requested_user
    user.try(:full_name)
  end

  def formatted_issued_at
    issued_at.try(:strftime, INOCRM_CONFIG['short_date_format'])
  end
  def store_name
    store.try(:name)
  end
  def ticket_no
    ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"])
  end
  def ticket_id
    ticket.try(:id)
  end
  def part_status
    spare_part_status_action.try(:name)
  end
  def rejected_reason
    part_terminated_reason.try(:reason)
  end
  belongs_to :ticket_spare_part, foreign_key: :ref_spare_part_id
  belongs_to :ticket, foreign_key: :ticket_id
  accepts_nested_attributes_for :ticket, allow_destroy: true
  belongs_to :spare_part_status_action, foreign_key: :status_action_id
  belongs_to :user, foreign_key: :requested_by
  belongs_to :store, class_name: "Organization", foreign_key: :store_id
  belongs_to :inventory_product, foreign_key: :inv_product_id
  belongs_to :main_inventory_product, class_name: "InventoryProduct", foreign_key: :main_inv_product_id
  belongs_to :spare_part_status_use,foreign_key: :status_use_id
  belongs_to :issued_by_user ,class_name: "User", foreign_key: :issued_by

  belongs_to :approved_store, class_name: "Organization", foreign_key: :approved_store_id
  belongs_to :approved_inventory_product, class_name: "InventoryProduct", foreign_key: :approved_inv_product_id
  belongs_to :approved_main_inventory_product, class_name: "InventoryProduct", foreign_key: :approved_main_inv_product_id

  belongs_to :return_part_damage_reason, class_name: "Reason"

  has_many :ticket_on_loan_spare_part_status_actions, foreign_key: :on_loan_spare_part_id
  accepts_nested_attributes_for :ticket_on_loan_spare_part_status_actions, allow_destroy: true

  has_many :request_on_loan_spare_parts, foreign_key: :ticket_on_loan_spare_part_id

  belongs_to :unused_reason, -> { where(spare_part_unused: true) }, class_name: "Reason", foreign_key: :unused_reason_id

  belongs_to :part_terminated_reason, -> { where(terminate_spare_part: true) }, class_name: "Reason", foreign_key: :part_terminated_reason_id

  belongs_to :gin, foreign_key: :inv_gin_id
  belongs_to :gin_item, foreign_key: :inv_gin_item_id

  belongs_to :srn, foreign_key: :inv_srn_id
  belongs_to :srn_item, foreign_key: :inv_srn_item_id

  belongs_to :srr, foreign_key: :inv_srr_id
  belongs_to :srr_item, foreign_key: :inv_srr_item_id
  belongs_to :engineer, class_name: "TicketEngineer", foreign_key: :engineer_id

end

class TicketOnLoanSparePartStatusAction < ActiveRecord::Base
  self.table_name = "spt_ticket_on_loan_spare_part_status_action"

  belongs_to :user, foreign_key: :done_by
  belongs_to :spare_part_status_action, foreign_key: :status_id
  belongs_to :ticket_on_loan_spare_part, foreign_key: :on_loan_spare_part_id

end

class ReturnPartsBundle < ActiveRecord::Base
  self.table_name = "spt_return_parts_bundle"

  belongs_to :product_brand

  has_many :ticket_spare_part_manufactures
  has_many :ticket_spare_parts, through: :ticket_spare_part_manufactures

  before_create do |return_part_bundle|
    return_part_bundle.bundle_no = CompanyConfig.first.increase_sup_last_bundle_no
  end

end

class TicketSparePartNonStock < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_non_stock"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :inventory_product, foreign_key: :inv_product_id
  belongs_to :approved_inventory_product, class_name: "mst_inv_product", foreign_key: :approved_inv_product_id

end