class Srr < ActiveRecord::Base
  self.table_name = "inv_srr"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :store, type: "nested", include_in_parent: true
    indexes :srr_items, type: "nested", include_in_parent: true
  end

  belongs_to :store, class_name: "Organization"
  belongs_to :requested_location, class_name: "Organization"
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :srr_items
  accepts_nested_attributes_for :srr_items, allow_destroy: true
  has_many :srr_item_sources, through: :srr_items

  has_many :ticket_spare_part_stores, foreign_key: :inv_srr_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srr_id

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :formated_created_at, lte: params[:range_to].to_date } if params[:range_to].present?
          must { range :formated_created_at, gte: params[:range_from].to_date } if params[:range_from].present?

        end
      end

      sort { by :formated_created_at, {order: "desc", ignore_unmapped: true} }

    end
  end

  def to_indexed_json
    to_json(
      only: [:id, :remarks, :created_at, :closed ],
      methods: [:store_name, :formatted_srr_no, :created_by_user_full_name, :formated_created_at],
      include: {
        store: {
          only: [:id, :name],
        },
        srr_items: {
          only: [:id, :closed, :quantity, :total_cost, :spare_part ],
          methods: [:currency_code],
          include: {
            inventory_product: {
              only: [:product_no, :model_no, :serial_no, :description],
            },
          },
        },
      },
    )

  end

  def store_name
    store.name
  end

  def formated_created_at
    created_at.to_date.strftime(INOCRM_CONFIG["short_date_format"])
  end

  def formatted_srr_no
    srr_no.to_s.rjust(6, INOCRM_CONFIG["inventory_srn_no_format"])
  end

  def created_by_user_full_name
    created_by_user.full_name
  end

end

class SrrItem < ActiveRecord::Base
  self.table_name = "inv_srr_item"

  belongs_to :srr
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :currency
  belongs_to :return_reason, -> { where(srr: true) }, class_name: "InventoryReason"

  has_many :srr_item_sources
  accepts_nested_attributes_for :srr_item_sources, allow_destroy: true

  has_many :grn_items
  accepts_nested_attributes_for :grn_items, allow_destroy: true

  has_many :gin_sources, through: :srr_item_sources

  has_many :ticket_spare_part_stores, foreign_key: :inv_srr_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srr_item_id

  def currency_code
    currency.code
  end

end

class SrrItemSource < ActiveRecord::Base
  self.table_name = "inv_srr_item_source"

  belongs_to :gin_source#, foreign_key: :grn_item_id
  belongs_to :srr_item#, foreign_key: :gin_item_id
end
