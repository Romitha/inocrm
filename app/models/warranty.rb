class Warranty < ActiveRecord::Base
  self.table_name = "spt_product_serial_warranty"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :product, type: "nested", include_in_parent: true
  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: (params[:per_page] || 10)) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :end_at, gte: params[:date_from].to_date.beginning_of_day } if params[:date_from].present?
          must { range :end_at, lte: params[:date_to].to_date.end_of_day } if params[:date_to].present?
        end
      end
      if params[:sort_by]
        sort { by :end_at, {order: "ASC", ignore_unmapped: true} }
      end
    end
  end

  def to_indexed_json
    Product
    to_json(
      only: [:id, :start_at, :end_at, :warranty_type_id, :created_at, :note, :updated_at],
      methods: [:warranty_type_name],
      include: {
        product: {
          only: [:id, :serial_no, :model_no, :product_no, :created_at, :owner_customer_id, :name, :description, :product_brand_id, :product_category_id, :updated_at],
          methods: [:category_full_name_index, :category_cat_id, :category_cat1_id, :category_cat2_id, :brand_name, :brand_id, :owner_customer_name, :location_address_full],
        },
      }
    )
  end
  
  def warranty_type_name
    warranty_type.try(:name)
  end
  belongs_to :warranty_type,-> { where(active: true) }

  belongs_to :product, foreign_key: :product_serial_id

  validates_presence_of [:warranty_type_id, :start_at, :end_at]
end

class WarrantyType < ActiveRecord::Base
  self.table_name = "mst_spt_warranty_type"

  has_many :warranties

  has_many :tickets

  has_many :action_warranty_repair_types, foreign_key: :ticket_warranty_type_id
end

class ActionWarrantyRepairType < ActiveRecord::Base
  self.table_name = "spt_act_warranty_repair_type"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_repair_type, foreign_key: :ticket_repair_type_id

  belongs_to :warranty_type,-> { where(active: true) }, foreign_key: :ticket_warranty_type_id

end

class ActionWarrantyExtend < ActiveRecord::Base
  self.table_name = "spt_act_warranty_extend"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :reject_reason, class_name: "Reason", foreign_key: :reject_reason_id

  validates :reject_reason_id, presence: true

end