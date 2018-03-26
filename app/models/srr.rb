class Srr < ActiveRecord::Base
  self.table_name = "inv_srr"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :store, class_name: "Organization"
  belongs_to :requested_location, class_name: "Organization"
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :srr_items
  has_many :grns

  accepts_nested_attributes_for :srr_items, allow_destroy: true
  has_many :srr_item_sources, through: :srr_items

  has_many :ticket_spare_part_stores, foreign_key: :inv_srr_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srr_id

  mapping do
    indexes :store, type: "nested", include_in_parent: true
    indexes :srr_items, type: "nested", include_in_parent: true
    indexes :grns, type: "nested", include_in_parent: true
    indexes :srr_item_sources, type: "nested", include_in_parent: true
  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: (params[:per_page] || 10)) do
      if params[:query]
        params[:query] = params[:query].split(" AND ").map{|q| q.starts_with?("formatted_srr_no") ? "("+q+" OR #{q.gsub('formatted_srr_no', 'srr_no')})" : q }.join(" AND ")
      end
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :created_at, lte: params[:range_to].to_date.end_of_day } if params[:range_to].present?
          must { range :created_at, gte: params[:range_from].to_date.beginning_of_day } if params[:range_from].present?

        end
      end

      sort { by :created_at, {order: "desc", ignore_unmapped: true} }

    end
  end

  def to_indexed_json
    Gin
    Srn
    to_json(
      only: [:id, :remarks, :created_at, :closed, :srr_no ],
      methods: [:store_name, :formatted_srr_no, :created_by_user_full_name, :formated_created_at],
      include: {
        store: {
          only: [:id, :name],
        },
        grns: {
          only: [:id],
        },
        srr_items: {
          only: [:id, :closed, :quantity, :total_cost, :spare_part ],
          methods: [:currency_code],
          include: {
            inventory_product: {
              only: [:product_no, :model_no, :serial_no, :description],
              include: {
                srn_items: {
                  only: [:id],
                  include: {
                    srn: {
                      only: [:id, :so_no],
                    }
                  }
                }
              }
            }
          },
        },
        srr_item_sources: {
          only: [:id ],
          include: {
            gin_source: {
              include: {
                gin_item: {
                  only: [:id, :gin_id],
                },
              },
            }
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

  def assign_srr_no
    self.srr_no = CompanyConfig.first.next_inv_last_srr_no
  end

  before_create :assign_srr_no

end

class SrrItem < ActiveRecord::Base
  self.table_name = "inv_srr_item"

  belongs_to :srr
  belongs_to :inventory_product,-> { where(active: true) }, foreign_key: :product_id
  belongs_to :currency
  belongs_to :return_reason, -> { where(srr: true) }, class_name: "InventoryReason"

  has_many :srr_item_sources
  accepts_nested_attributes_for :srr_item_sources, allow_destroy: true

  has_many :grn_items
  accepts_nested_attributes_for :grn_items, allow_destroy: true

  has_many :gin_sources, through: :srr_item_sources

  has_many :ticket_spare_part_stores, foreign_key: :inv_srr_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srr_item_id

  attr_accessor :returned_quantity
  attr_accessor :issued_quantity

  def currency_code
    currency.try(:code)
  end

  before_save do |srr_item|
   srr_item_remarks = if srr_item.persisted? and srr_item.remarks_changed? and srr_item.remarks.present?
      "#{srr_item.remarks} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(srr_item.current_user_id).try(:full_name)}</span><br/>#{srr_item.remarks_was}"
    else
      srr_item.remarks_was
    end
    srr_item.remarks = srr_item_remarks
  end

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

class SrrItemSource < ActiveRecord::Base
  self.table_name = "inv_srr_item_source"

  Gin

  belongs_to :gin_source#, foreign_key: :grn_item_id
  belongs_to :srr_item#, foreign_key: :gin_item_id
end
