class Grn < ActiveRecord::Base
  self.table_name = "inv_grn"

  belongs_to :store, class_name: "Organization"
  belongs_to :srn
  belongs_to :inventory_po, foreign_key: :po_id

  has_many :grn_items

end

class GrnItem < ActiveRecord::Base
  self.table_name = "inv_grn_item"

  belongs_to :srn_item
  belongs_to :grn
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :currency

  has_many :grn_batches
  accepts_nested_attributes_for :grn_batches, allow_destroy: true
  has_many :inventory_batches, through: :grn_batches
  accepts_nested_attributes_for :inventory_batches, allow_destroy: true

  has_many :grn_serial_items, foreign_key: :grn_item_id
  accepts_nested_attributes_for :grn_serial_items, allow_destroy: true
  has_many :inventory_serial_item_for_grn_serial_items, through: :grn_serial_items

  has_many :grn_serial_parts, foreign_key: :grn_item_id
  has_many :inventory_serial_item_for_grn_serial_parts, through: :grn_serial_parts
  has_many :inventory_serial_parts, through: :grn_serial_parts

  has_many :damages
  accepts_nested_attributes_for :damages, allow_destroy: true

  has_many :gin_sources
  has_many :gin_serial_parts
  has_many :grn_item_current_unit_cost_histories

  has_many :dyna_columns, as: :resourceable, autosave: true

  [:flagged_as].each do |dyna_method|
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
end

class GrnBatch < ActiveRecord::Base
  self.table_name = "inv_grn_batch"

  belongs_to :grn_item
  belongs_to :inventory_batch
  accepts_nested_attributes_for :inventory_batch, allow_destroy: true

  has_many :gin_sources
  has_many :damages

  validates_presence_of :recieved_quantity

end

class GrnSerialItem < ActiveRecord::Base
  self.table_name = "inv_grn_serial_item"

  belongs_to :grn_item, foreign_key: :grn_item_id
  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_item, allow_destroy: true

  has_many :gin_sources#, foreign_key: :gin_item_id
  has_many :damages

end

class GrnSerialPart < ActiveRecord::Base
  self.table_name = "inv_grn_serial_part"

  belongs_to :grn_item
  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  belongs_to :inventory_serial_part, foreign_key: :inv_serial_part_id

  has_many :gin_sources, foreign_key: :grn_serial_part_id

end

class GrnItemCurrentUnitCostHistory < ActiveRecord::Base
  self.table_name = "inv_grn_item_current_unit_cost_history"

  belongs_to :grn_item
  belongs_to :created_by_user, foreign_key: :created_by
end