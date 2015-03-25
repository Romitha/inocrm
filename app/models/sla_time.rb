class SlaTime < ActiveRecord::Base
	self.table_name = "mst_spt_sla"

	has_many :tickets, foreign_key: :sla_id
	has_many :product_brands, foreign_key: :sla_id
	has_many :product_categories, foreign_key: :sla_id

	validates_presence_of [:sla_time, :description]
	validates_numericality_of :sla_time
end
