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

  has_one :ticket_spare_part_store, foreign_key: :spare_part_id
  accepts_nested_attributes_for :ticket_spare_part_store, allow_destroy: true

  has_one :ticket_spare_part_non_stock, foreign_key: :spare_part_id
  accepts_nested_attributes_for :ticket_spare_part_non_stock, allow_destroy: true

  has_many :ticket_on_loan_spare_parts, foreign_key: :ref_spare_part_id
  accepts_nested_attributes_for :ticket_on_loan_spare_parts, allow_destroy: true

  belongs_to :unused_reason, -> { where(spare_part_unused: true) }, class_name: "Reason", foreign_key: :unused_reason_id

  belongs_to :part_terminated_reason, -> { where(terminate_spare_part: true) }, class_name: "Reason", foreign_key: :part_terminated_reason_id

  has_many :ticket_estimation_parts, foreign_key: :ticket_spare_part_id

  has_many :so_po_items, foreign_key: :ticket_spare_part_id

  after_save :flush_cache

  validates_presence_of :spare_part_description

  before_save do |ticket_spare_part|
    ticket_spare_part.note = "#{self.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket_spare_part.current_user_id).email}</span><br/>#{ticket_spare_part.note_was}" if ticket_spare_part.persisted? and self.note_changed? and self.note.present?
  end

  def flush_cache
    Rails.cache.delete([self.ticket.id, :ticket_spare_parts])
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
end

class SoPo < ActiveRecord::Base
  self.table_name = "spt_so_po"

  has_many :so_po_items, foreign_key: :spt_so_po_id
  validates :po_no, :po_date, :so_no, :amount, presence: true
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
end

class TicketFsr < ActiveRecord::Base
  self.table_name = "spt_ticket_fsr"

  belongs_to :ticket
  accepts_nested_attributes_for :ticket
  # validates_presence_of [:work_started_at, :work_finished_at, :hours_worked, :hours_worked, :down_time, :travel_hours, :engineer_time_travel, :engineer_time_on_site, :resolution, :completion_level]

  has_one :act_fsr, foreign_key: :fsr_id
  accepts_nested_attributes_for :act_fsr, allow_destroy: true

  has_many :ticket_spare_parts, foreign_key: :fsr_id


  before_save do |ticket_fsr|
    ticket_fsr.remarks = "#{self.remarks} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket_fsr.current_user_id).email}</span><br/>#{ticket_fsr.remarks_was}" if ticket_fsr.persisted? and self.remarks_changed? and self.remarks.present?
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

  has_many :deliver_units, foreign_key: :ticket_deliver_unit_id
  accepts_nested_attributes_for :deliver_units, allow_destroy: true

  has_many :dyna_columns, as: :resourceable, autosave: true

  before_save do |ticket_deliver_unit|
    ticket_deliver_unit.note = "#{self.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(self.current_user_id).email}</span><br/>#{self.note_was}" if ticket_deliver_unit.persisted? and self.note_changed? and self.note.present?
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
end

class TicketSparePartManufacture < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_manufacture"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :manufacture_currency, class_name: "Currency", foreign_key: :manufacture_currency_id
  belongs_to :return_parts_bundle

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

  belongs_to :ticket_spare_part, foreign_key: :ref_spare_part_id
  belongs_to :ticket, foreign_key: :ticket_id
  accepts_nested_attributes_for :ticket, allow_destroy: true
  belongs_to :spare_part_status_action, foreign_key: :status_action_id
  belongs_to :user, foreign_key: :requested_by
  belongs_to :store, class_name: "Organization", foreign_key: :store_id
  belongs_to :inventory_product, foreign_key: :inv_product_id
  belongs_to :main_inventory_product, class_name: "InventoryProduct", foreign_key: :main_inv_product_id
  belongs_to :spare_part_status_use, foreign_key: :status_use_id

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