class Gin < ActiveRecord::Base
  self.table_name = "inv_gin"
  belongs_to :store, class_name: "Organization"
  belongs_to :srn
  belongs_to :user

  has_many :gin_items
  accepts_nested_attributes_for :gin_items, allow_destroy: true
  has_many :ticket_spare_part_stores, foreign_key: :inv_gin_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_gin_id

  before_save do |gin|
   if gin.persisted? and gin.remarks_changed? and gin.remarks.present?
      gin_remarks = "#{gin.remarks} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(gin.current_user_id).email}</span><br/>#{gin.remarks_was}"
    else
      gin_remarks = gin.remarks_was
    end
    gin.remarks = gin_remarks
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

class GinItem < ActiveRecord::Base
  self.table_name = "inv_gin_item"

  belongs_to :gin
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :srn_item, foreign_key: :srn_item_id
  belongs_to :currency
  belongs_to :product_condition

  has_many :gin_sources#, foreign_key: :gin_item_id
  has_many :ticket_spare_part_stores, foreign_key: :inv_gin_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_gin_item_id
end

class GinSource < ActiveRecord::Base
  self.table_name = "inv_gin_source"

  belongs_to :gin_item#, foreign_key: :gin_item_id
  belongs_to :grn_item#, foreign_key: :grn_item_id
  belongs_to :grn_batch#, foreign_key: :gin_item_id
  belongs_to :grn_serial_item#, foreign_key: :gin_item_id
  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :main_part_grn_serial_item, class_name: "GrnSerialItem", foreign_key: :main_part_grn_serial_item_id

  has_many :srr_item_sources
  has_many :srr_items, through: :srr_item_sources
end