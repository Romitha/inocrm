class Ticket < ActiveRecord::Base
  self.table_name = "spt_ticket"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :products, type: "nested", include_in_parent: true
    indexes :customer, type: "nested", include_in_parent: true
    indexes :ticket_status, type: "nested", include_in_parent: true
    indexes :district, type: "nested", include_in_parent: true
    indexes :owner_engineer, type: "nested", include_in_parent: true
    indexes :ticket_contract, type: "nested", include_in_parent: true 

  end

  def self.search(params)
    all_page = {page: (params[:page] || 1)}
    if params[:from_where] == "job_ticket"
      all_page.merge!({per_page: 1000})
    elsif params[:from_where] != "excel_output"
      all_page.merge!({per_page: 10})
    else
      all_page.merge!({per_page: (params[:per_page] || 10)})
    end

    tire.search(all_page) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          must { range :created_at, lte: params[:range_to].to_date } if params[:range_to].present?
          must { range :created_at, gte: params[:range_from].to_date } if params[:range_from].present?

          must { range :logged_at, lte: params[:l_range_to].to_date } if params[:l_range_to].present?
          must { range :logged_at, gte: params[:l_range_from].to_date } if params[:l_range_from].present?

          if not params[:report].present?
            must { range :ticket_contract_contract_start_at, gte: params[:ticket_contract_contract_start_at].to_date.beginning_of_day } if params[:ticket_contract_contract_start_at].present?
            must { range :ticket_contract_contract_end_at, lte: params[:ticket_contract_contract_end_at].to_date.end_of_day } if params[:ticket_contract_contract_end_at].present?
          end
          if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present? and params[:report].present?
            must { range :ticket_contract_contract_start_at, lte: params[:ticket_contract_contract_start_at].to_date.beginning_of_day } 
            must { range :ticket_contract_contract_end_at, gte: params[:ticket_contract_contract_end_at].to_date.end_of_day } 
          end
        end
      end
      # sort { by :created_at, {order: "asc", ignore_unmapped: true} }
      sort { by :ticket_no, {order: "desc", ignore_unmapped: true} }
      highlight customer_name: {number_of_fragments: 0}, ticket_status_name: {number_of_fragments: 0}, :options => { :tag => '<strong class="highlight">' } if params[:query].present?
      # filter :range, published_at: { lte: Time.zone.now}
      # raise to_curl
    end
  end

  def to_indexed_json
    Warranty
    ContactNumber
    TaskAction
    User
    Invoice
    to_json(
      only: [:created_at, :cus_chargeable, :id, :ticket_no, :logged_at, :slatime, :job_started_at, :job_started_action_id, :problem_description, :job_type_id, :job_finished_at, :status_hold, :re_open_count, :final_invoice_id, :resolution_summary, :updated_at],
      methods: [:customer_name,:ticket_support_engineer_cost,:ticket_additional_cost,:ticket_external_cost, :ticket_engineer_cost, :ticket_part_cost, :ticket_contract_contract_end_at, :ticket_contract_contract_start_at, :job_type_get, :owner_engineer_name, :ticket_status_name, :warranty_type_name, :support_ticket_no, :ticket_type_name, :ticket_contract_product_amount, :ticket_contract_location],
      include: {
        ticket_contract: {
          only: [ :id, :customer_id, :products, :contract_no,:amount, :contract_start_at,:contract_end_at, :season, :accepted_at, :updated_at],
          methods: [:brand_name, :category_cat_id, :category_name, :payment_type, :formated_contract_start_at, :formated_contract_end_at, :product_amount,:discount_less_amount, :contract_no_genarate],
          include: {
            contract_products:{
              only: [:id, :amount,:installed_location_id, :remarks, :product_serial_id, :updated_at],
            },
            organization: {
              only: [:id, :name, :code, :updated_at],
              methods: [:get_organization_account_manager],
              include: {
                account: {
                  only: [:id, :industry_types_id],
                  methods: [:get_account_manager, :get_account_manager_id],
                  include: {
                    industry_type: {
                      only: [:id, :name, :code],
                    },
                  },
                },
              },
            },
            ticket_contract_type: {
              only: [:id, :name, :contract_no_value],
            },
            ticket_currency: {
              only: [:id, :code],
            },
            owner_organization: {
              only: [:id, :name, :updated_at],
            },
            ticket_contract_payment_type: {
              only: [:id, :name],
            },
            contract_payment_receiveds: {
              only: [:id, :amount],
            },
          },
        },
        products: {
          only: [:id, :serial_no, :model_no, :product_no, :created_at, :name, :updated_at],
          methods: [:category_full_name_index, :category_cat_id, :brand_name],
        },
        customer: {
          only: [:id, :name, :address1, :address2, :address3, :address4],
          include: {
            contact_type_values: {
              only: [:id, :value, :contact_type_id],
            },
            organization: {
              only: [:id, :address1, :address2, :address3, :address4],
            },
            district: {
              only: [:id, :name],
            },
          }
        },
        ticket_spare_parts: {
          only: [:id, :spare_part_no, :spare_part_description, :request_from],
          methods: [:inventory_product_generated_serial_item],
          include: {
            ticket_spare_part_manufacture: {
              only: [:id, :event_no],
            },
          }
        },
        hp_cases: {
          only: [:ticket_action_id, :case_id],
        },
        ticket_start_action: {
          only: [:id, :action]
        },
        owner_engineer: {
          only: [:id, :created_at, :created_action_id, :user_id, :job_completed_at, :updated_at],
          methods: [:sbu_name, :full_name],
          include: {
            user: {
              only: [:id, :last_name],
              methods: [:full_name]
            },
          }
        },
        reason: {
          only: [:id, :reason],
        },
        final_invoice: {
          only: [:id, :total_amount, :total_deduction],
        },
        ticket_status: {
          only: [:id, :name],
        },
      }
    )

  end

  def ticket_contract_contract_end_at
    ticket_contract.try(:contract_end_at)
  end

  def ticket_contract_contract_start_at
    ticket_contract.try(:contract_start_at)
  end



  def ticket_part_cost
    ticket_total_cost.try(:part_cost).to_f
  end


  def ticket_engineer_cost
    ticket_total_cost.try(:engineer_cost).to_f
  end
  
  def ticket_support_engineer_cost
    ticket_total_cost.try(:support_engineer_cost).to_f
  end


  def ticket_additional_cost
    ticket_total_cost.try(:additional_cost).to_f
  end

  def ticket_external_cost
    ticket_total_cost.try(:external_cost).to_f
  end

  def job_type_get
    job_type.try(:name)
  end

  def ticket_contract_product_amount
    if ticket_contract.present? and products.first.present?
      # ticket_contract.contract_products.where(product_serial_id: products.first.id).sum(:amount).to_f
      ticket_contract.contract_products.where(product_serial_id: products.first.id).sum(:amount).to_f
    end
  end
  
  def ticket_contract_location
    if ticket_contract.present? and products.first.present?
      # ticket_contract.contract_products.where(product_serial_id: products.first.id).sum(:amount).to_f
      ticket_contract.contract_products.where(product_serial_id: products.first.id).try(:installed_location).try(:full_address)
    end
  end

  def ticket_type_name
    ticket_type.name
  end

  def customer_name
    customer.full_name
  end

  def ticket_status_name
    ticket_status.name
  end

  def warranty_type_name
    warranty_type.name
  end

  def support_ticket_no
    ticket_no.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"])
  end

  def update_on_create_ticket_info
    Organization
    update ticket_no: (CompanyConfig.first.sup_last_ticket_no.to_i+1) #(self.class.any? ? (self.class.order("created_at ASC").map{|t| t.ticket_no.to_i}.max + 1) : 1)
    CompanyConfig.first.increment! :sup_last_ticket_no, 1

  end


  def cached_user_ticket_actions
    Rails.cache.fetch([self.id, :user_ticket_actions]){ self.user_ticket_actions.to_a }
  end

  def cached_ticket_spare_parts
    Rails.cache.fetch([self.id, :ticket_spare_parts]){ self.ticket_spare_parts.to_a }
  end

  def cached_ticket_estimations
    Rails.cache.fetch([self.id, :ticket_estimations]){ self.ticket_estimations.to_a }
  end

  def logged_by_user
    User.cached_find_by_id(logged_by).try(:full_name)
  end

  def flash_cache
    Organization

    Rails.cache.delete([:join, self.id])
    true

  end

  def set_ticket_close(user_id)
    manufacture_parts_po_completed = !ticket_spare_parts.any? { |t| t.ticket_spare_part_manufacture.try(:po_required) and not t.ticket_spare_part_manufacture.try(:po_completed) }

    if job_closed and (cus_payment_completed or !cus_payment_required) and (ticket_close_approved or !ticket_close_approval_required) and manufacture_parts_po_completed and status_id == TicketStatus.find_by_code("TBC").id
      update status_id: TicketStatus.find_by_code("CLS").id, ticket_closed_at: DateTime.now # Ticket Closed

      # 87 - Close Ticket
      user_ticket_action = user_ticket_actions.build(action_id: TaskAction.find_by_action_no(87).id, action_at: DateTime.now, action_by: user_id, re_open_index: re_open_count)
      user_ticket_action.save
    end
  end

  def ticket_closed?
    ["CLS", "TBC"].include? ticket_status.try(:code)
  end

  def calculate_ticket_total_cost

    engineer_cost = 0
    engineer_time = 0
    sup_engineer_time = 0
    sup_engineer_cost = 0
    part_cost = 0
    additional_cost = 0
    external_cost = 0

    engineer_time += (ticket_engineers.sum(:job_actual_time_spent) + (ticket_fsrs.sum(:hours_worked) * 60)) #In Minutes
    
    sup_engineer_time += (ticket_engineers.to_a.sum{ |ticket_engineer|  ticket_engineer.ticket_support_engineers.sum(:job_actual_time_spent) } + (ticket_fsrs.to_a.sum{ |fsr|  fsr.ticket_fsr_support_engineers.sum(:hours_worked) } * 60)) #In Minutes

    ticket_estimations.each do |ticket_estimation|
      # if (!ticket_estimation.approval_required or (ticket_estimation.approval_required and ticket_estimation.approved)) and (!ticket_estimation.cust_approval_required or (ticket_estimation.cust_approval_required and ticket_estimation.cust_approved))
      if !((ticket_estimation.approval_required and !ticket_estimation.approved) or (ticket_estimation.cust_approval_required and !ticket_estimation.cust_approved))

        part_cost += ticket_estimation.ticket_estimation_parts.sum(:cost_price)
        additional_cost += ticket_estimation.ticket_estimation_additionals.sum(:cost_price)
        external_cost += ticket_estimation.ticket_estimation_externals.sum(:cost_price)
      end
    end

    brand_costs = products.first.product_brand.product_brand_costs.where(currency_id: base_currency_id)
    if brand_costs.present?
      engineer_cost = engineer_time * brand_costs.first.engineer_cost / 60 #per hour
      sup_engineer_cost = sup_engineer_time * brand_costs.first.support_engineer_cost / 60 #per hour
    end

    ticket_total_cost_params = {engineer_time_spent: engineer_time, support_engineer_time_spent: sup_engineer_time, engineer_cost: engineer_cost, support_engineer_cost: sup_engineer_cost, part_cost: part_cost, additional_cost: additional_cost, external_cost: external_cost}

    ticket_total_cost.present? ? ticket_total_cost.update(ticket_total_cost_params) : create_ticket_total_cost(ticket_total_cost_params)
    if ticket_contract.present?
      ticket_contract.contract_products.each(&:update_index)
    end

  end

  def re_open_ticket(re_open_action_id, engineer_id = nil)
    re_opened_engineer_ids = []
    max_channel_no = ticket_engineers.pluck(:channel_no).max

    start_engineer = if engineer_id.present?
      ticket_engineers.find engineer_id
    else
      channel_no = 1
      init_queued_engineer = ticket_engineers.where(channel_no: channel_no, order_no: 1).first

      begin
        unless init_queued_engineer.present?
          channel_no += 1
          init_queued_engineer = ticket_engineers.where(channel_no: channel_no, order_no: 1).first 
        end
        init_engineer = init_queued_engineer if init_queued_engineer and !init_queued_engineer.re_assignment_requested and init_queued_engineer.re_open_index.to_i == 0 and init_queued_engineer.status > 0
        init_queued_engineer = (init_queued_engineer and init_queued_engineer.sub_engineers.first)

      end until init_engineer.present? or max_channel_no < channel_no

      init_engineer

    end
    current_engineer = start_engineer if !start_engineer.re_assignment_requested and start_engineer.re_open_index.to_i == 0 and start_engineer.status > 0
    parent_engineer = nil

    order_no = start_engineer.order_no.to_i

    until current_engineer.blank?
      new_engineer = ticket_engineers.build current_engineer.attributes.select{|a| ["user_id", "sbu_id", "re_assignment_requested", "channel_no"].include? a}
      new_engineer.attributes = {created_action_id: re_open_action_id, re_open_index: self.re_open_count}

      parent_engineer = nil if order_no == 1

      new_engineer.parent_engineer = parent_engineer
      new_engineer.order_no = order_no

      new_engineer.save

      current_engineer.ticket_support_engineers.update_all(engineer_id: new_engineer.id)

      # re_opened_engineer_ids << [new_engineer.id]
      re_opened_engineer_ids << new_engineer.id

      parent_engineer = new_engineer

      # current_engineer = current_engineer.sub_engineers.first
      queued_current_engineer = current_engineer.sub_engineers.first

      begin
        current_engineer = if queued_current_engineer.present? and !queued_current_engineer.re_assignment_requested and queued_current_engineer.re_open_index.to_i == 0 and queued_current_engineer.status > 0
          queued_current_engineer
        else
          nil
        end
        queued_current_engineer = (queued_current_engineer.present? and queued_current_engineer.sub_engineers.first)

      end until current_engineer.present? or queued_current_engineer.blank?

      order_no += 1

      unless current_engineer.present? or engineer_id.present?
        current_engineer = ticket_engineers.where(channel_no: (new_engineer.channel_no+1), order_no: 1, re_open_index: 0 ).first
        order_no = current_engineer.try(:order_no).to_i
      end

    end

    re_opened_engineer_ids

  end

  belongs_to :ticket_type, foreign_key: :ticket_type_id
  belongs_to :warranty_type, foreign_key: :warranty_type_id
  belongs_to :job_type, foreign_key: :job_type_id
  belongs_to :inform_method, foreign_key: :informed_method_id
  belongs_to :problem_category, foreign_key: :problem_category_id
  belongs_to :ticket_contact_type, foreign_key: :contact_type_id
  belongs_to :ticket_contract, foreign_key: :contract_id
  belongs_to :ticket_status, foreign_key: :status_id
  belongs_to :ticket_currency, foreign_key: :base_currency_id
  belongs_to :customer, foreign_key: :customer_id

  belongs_to :contact_person1, foreign_key: :contact_person1_id
  belongs_to :contact_person2, foreign_key: :contact_person2_id
  belongs_to :report_person, foreign_key: :reporter_id
  belongs_to :sla_time, foreign_key: :sla_id
  belongs_to :ticket_status_resolve, foreign_key: :status_resolve_id
  belongs_to :repair_type, foreign_key: :repair_type_id
  belongs_to :manufacture_currency, class_name: "Currency", foreign_key: :manufacture_currency_id
  belongs_to :ticket_start_action, foreign_key: :job_started_action_id
  belongs_to :ticket_repair_type, foreign_key: :repair_type_id
  belongs_to :reason, foreign_key: :hold_reason_id
  belongs_to :owner_engineer, class_name: "TicketEngineer"
  belongs_to :owner_organization, class_name: "Organization"

  has_many :ticket_product_serials, foreign_key: :ticket_id
  has_many :products, through: :ticket_product_serials
  accepts_nested_attributes_for :products, allow_destroy: true
  has_many :customer_quotations, foreign_key: :ticket_id
  accepts_nested_attributes_for :customer_quotations, allow_destroy: true

  has_many :q_and_answers, foreign_key: :ticket_id
  has_many :q_and_as, through: :q_and_answers
  accepts_nested_attributes_for :q_and_answers, allow_destroy: true, :reject_if => :all_blank

  has_many :ge_q_and_answers
  accepts_nested_attributes_for :ge_q_and_answers, allow_destroy: true

  has_many :ticket_accessories, foreign_key: :ticket_id
  has_many :accessories, through: :ticket_accessories
  accepts_nested_attributes_for :ticket_accessories, allow_destroy: true


  has_many :dyna_columns, as: :resourceable, autosave: true

  has_many :joint_tickets
  accepts_nested_attributes_for :joint_tickets, allow_destroy: true

  has_many :user_ticket_actions#, foreign_key: :action_id
  accepts_nested_attributes_for :user_ticket_actions, allow_destroy: true

  has_many :ticket_extra_remarks, foreign_key: :ticket_id
  has_many :extra_remarks, through: :ticket_extra_remarks
  accepts_nested_attributes_for :ticket_extra_remarks, allow_destroy: true

  has_many :ticket_workflow_processes


  has_many :ticket_spare_parts
  accepts_nested_attributes_for :ticket_spare_parts, allow_destroy: true

  has_many :ticket_on_loan_spare_parts
  accepts_nested_attributes_for :ticket_on_loan_spare_parts, allow_destroy: true, reject_if: :all_blank


  has_many :ticket_fsrs
  accepts_nested_attributes_for :ticket_fsrs, allow_destroy: true

  has_many :ticket_deliver_units
  accepts_nested_attributes_for :ticket_deliver_units, allow_destroy: true

  has_many :act_terminate_job_payments
  accepts_nested_attributes_for :act_terminate_job_payments, allow_destroy: true

  has_many :ticket_estimations, foreign_key: :ticket_id
  accepts_nested_attributes_for :ticket_estimations, allow_destroy: true

  has_many :ticket_estimation_parts, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :ticket_estimation_parts, allow_destroy: true

  has_many :ticket_estimation_externals, foreign_key: :ticket_id
  accepts_nested_attributes_for :ticket_estimation_externals, allow_destroy: true

  has_many :ticket_estimation_additionals, foreign_key: :ticket_id
  accepts_nested_attributes_for :ticket_estimation_additionals, allow_destroy: true

  has_many :customer_quotations, foreign_key: :ticket_id
  accepts_nested_attributes_for :customer_quotations, allow_destroy: true

  has_many :ticket_invoices, foreign_key: :ticket_id
  accepts_nested_attributes_for :ticket_invoices, allow_destroy: true
  belongs_to :final_invoice, class_name: "TicketInvoice", foreign_key: :final_invoice_id

  has_many :ticket_payment_receiveds
  accepts_nested_attributes_for :ticket_payment_receiveds, allow_destroy: true
  has_many :invoices, through: :ticket_payment_receiveds

  has_many :ticket_engineers, class_name: "TicketEngineer", foreign_key: :ticket_id
  has_many :users, through: :ticket_engineers


  belongs_to :onsite_type
  accepts_nested_attributes_for :onsite_type, allow_destroy: true

  has_many :hp_cases, through: :user_ticket_actions

  has_one :ticket_total_cost

  validates_presence_of [:ticket_no, :priority, :status_id, :problem_description, :informed_method_id, :job_type_id, :ticket_type_id, :warranty_type_id, :base_currency_id, :problem_category_id]

  validates_numericality_of [:ticket_no, :priority]
  validates_inclusion_of :cus_chargeable, in: [true, false]

  before_save do |ticket|
    if ticket.persisted? and ticket.remarks_changed? and ticket.remarks.present?
      ticket_remarks = "#{ticket.remarks} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket.current_user_id).full_name}</span><br/>#{ticket.remarks_was}"
    elsif ticket.new_record?
      ticket_remarks = ticket.remarks  
    else
      ticket_remarks = ticket.remarks_was
    end
    ticket.remarks = ticket_remarks
  end

  [:initiated_by, :initiated_by_id, :current_user_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save# if data.persisted?
    end
  end

  after_create :update_on_create_ticket_info

  after_update :flash_cache

end

class OnsiteType < ActiveRecord::Base
  self.table_name = "mst_spt_onsite_type"
  has_many :ticket#, foreign_key: :onsite_type_id

end

class TicketType < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_type"

  has_many :tickets, foreign_key: :ticket_type_id

  validates_presence_of [:code, :name]
end

class JobType < ActiveRecord::Base
  self.table_name = "mst_spt_job_type"

  has_many :tickets, foreign_key: :job_type_id

  validates_presence_of [:code, :name]
end

class InformMethod < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_informed_method"

  has_many :tickets, foreign_key: :informed_method_id

  validates_presence_of [:code, :name]
end

class ProblemCategory < ActiveRecord::Base
  self.table_name = "spt_problem_category"

  has_many :tickets, foreign_key: :problem_category_id

  has_many :q_and_as, foreign_key: :problem_category_id
  accepts_nested_attributes_for :q_and_as, allow_destroy: true

  validates_presence_of [:name]
  validates_uniqueness_of :name

  def is_used_anywhere?
    tickets.any? or q_and_as.any?
  end

end

class TicketContactType < ActiveRecord::Base
  self.table_name = "mst_spt_contact_type"

  has_many :tickets, foreign_key: :contact_type_id

  has_many :inform_customers, foreign_key: :contact_type_id
  accepts_nested_attributes_for :inform_customers, allow_destroy: true

  validates_presence_of [:code, :name]
end

class TicketContractType < ActiveRecord::Base
  self.table_name = "mst_spt_contract_type"

end

class TicketContract < ActiveRecord::Base
  self.table_name = "spt_contract"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  # mount_uploader :attachment_url, AttachmentUrlUploader

  has_many :tickets, foreign_key: :contract_id
  has_many :contract_products, foreign_key: :contract_id
  has_many :contract_payment_receiveds, foreign_key: :contract_id
  has_many :contract_attachments, class_name: 'Documents::ContractAttachment', foreign_key: :contract_id
  accepts_nested_attributes_for :contract_attachments, allow_destroy: true
  has_many :contract_documents, class_name: 'Documents::ContractDocument', foreign_key: :contract_id
  accepts_nested_attributes_for :contract_documents, allow_destroy: true

  accepts_nested_attributes_for :contract_products, allow_destroy: true
  accepts_nested_attributes_for :contract_payment_receiveds, allow_destroy: true
  has_many :products, through: :contract_products

  belongs_to :sla_time, foreign_key: :sla_id
  belongs_to :organization, foreign_key: :customer_id
  belongs_to :ticket_contract_type, foreign_key: :contract_type_id
  belongs_to :ticket_currency, foreign_key: :currency_id
  belongs_to :organization_contact_person, foreign_key: :contact_person_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by
  belongs_to :product_brand, foreign_key: :product_brand_id
  belongs_to :product_category, foreign_key: :product_category_id
  belongs_to :ticket_contract_payment_type, foreign_key: :payment_type_id 
  belongs_to :contract_status, foreign_key: :status_id 

  belongs_to :organization_contact, class_name: "Organization"
  belongs_to :organization_bill, class_name: "Organization"

  # belongs_to :organization_contact_addresses, foreign_key: :bill_address
  belongs_to :contact_address, class_name: "Address"
  belongs_to :bill_address, class_name: "Address"
  belongs_to :owner_organization, class_name: "Organization"

  validates_presence_of [:customer_id, :sla_id, :created_by]

  validates_numericality_of [:sla_id]
  validates_uniqueness_of :contract_no

  mapping do
    indexes :organization, type: "nested", include_in_parent: true
    indexes :ticket_contract_type, type: "nested", include_in_parent: true
    indexes :owner_organization, type: "nested", include_in_parent: true
    indexes :organization_contact_person, type: "nested", include_in_parent: true
    indexes :ticket_contract_payment_type, type: "nested", include_in_parent: true
    indexes :contract_payment_receiveds, type: "nested", include_in_parent: true
    # indexes :organization_contact_addresses, type: "nested", include_in_parent: true
    # indexes :supplier, type: "nested", include_in_parent: true
    # indexes :store, type: "nested", include_in_parent: true
    # indexes :inventory_po_items, type: "nested", include_in_parent: true

  end

  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: (params[:per_page] || 10)) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          if not params[:report_summery].present?
            if not params[:report].present?
              puts "not inside report"
              must { range :contract_start_at, gte: params[:contract_date_from].to_date.beginning_of_day } if params[:contract_date_from].present?
              must { range :contract_end_at, lte: params[:contract_date_to].to_date.end_of_day } if params[:contract_date_to].present?
            end
          end
          # must { range :created_at, lte: params[:po_date_to].to_date.end_of_day  } if params[:po_date_to].present?
          # must { range :created_at, gte: params[:po_date_from].to_date.beginning_of_day } if params[:po_date_from].present?
          # must { term :author_id, params[:author_id] } if params[:author_id].present?
          if params[:contract_date_from].present? and params[:contract_date_to].present? and params[:report].present?
            puts "inside report"
            must { range :contract_start_at, lte: params[:contract_date_from].to_date.beginning_of_day }
            must { range :contract_end_at, gte: params[:contract_date_to].to_date.end_of_day }
          end
          if params[:contract_date_from].present? and params[:report_summery].present?
            must { range :contract_start_at, lte: params[:contract_date_from].to_date.beginning_of_day }
            must { range :contract_end_at, gte: params[:contract_date_from].to_date.end_of_day }
            # must { range :contract_end_at, gte: params[:contract_date_from].to_date.end_of_day }
          end

        end
      end
      if params[:sort_by]
        sort { by :season, {order: "asc", ignore_unmapped: true} }
      else
        sort { by :created_at, {order: "desc", ignore_unmapped: true} }
      end
      # highlight customer_name: {number_of_fragments: 0}, ticket_status_name: {number_of_fragments: 0}, :options => { :tag => '<strong class="highlight">' } if params[:query].present?
      # filter :range, published_at: { lte: Time.zone.now}
      # raise to_curl
    end
  end

  def to_indexed_json
    Organization
    ContactNumber
    Invoice
    to_json(
      only: [ :id, :created_at, :created_by, :customer_id, :products, :contract_no, :hold, :amount, :payment_completed, :contract_start_at,:contract_end_at, :season, :accepted_at, :updated_at, :remarks],
      methods: [:num_of_products, :brand_name, :category_cat_id, :category_name, :payment_type, :formated_created_at, :created_by_user_full_name, :formated_contract_start_at, :formated_contract_end_at, :dynamic_active, :formated_accepted_at, :product_amount,:discount_less_amount, :contract_no_genarate],
      include: {
        organization: {
          only: [:id, :name, :code, :updated_at],
          methods: [:get_organization_account_manager],
          include: {
            account: {
              only: [:id, :industry_types_id],
              methods: [:get_account_manager, :get_account_manager_id],
              include: {
                industry_type: {
                  only: [:id, :name, :code],
                },
              },
            },
          },
        },
        ticket_contract_type: {
          only: [:id, :name, :contract_no_value],
        },
        ticket_currency: {
          only: [:id, :code],
        },
        owner_organization: {
          only: [:id, :name, :updated_at],
        },
        organization_contact_person: {
          only: [:id, :name],
        },
        ticket_contract_payment_type: {
          only: [:id, :name],
        },
        contract_payment_receiveds: {
          only: [:id, :amount],
        },
      },
    )

  end

  before_create :contract_no_increase

  def contract_no_increase
    contract_no = CompanyConfig.first.increase_sup_last_contract_serial_no
    self.contract_no = contract_no

  end

  def contract_no_genarate
    "#{contract_start_at.try(:strftime, "%y")}-#{owner_organization.try(:contract_no_value)}-#{product_brand.try(:contract_no_value)}-#{product_category.try(:contract_no_value)}-#{ticket_contract_type.try(:contract_no_value)}-#{contract_no}"
    # self.contract_no = "#{contract_start_at.try(:strftime, "%y")}-#{owner_organization.try(:contract_no_value)}-#{product_brand.try(:contract_no_value)}-#{product_category.try(:contract_no_value)}-#{ticket_contract_type.try(:contract_no_value)}-#{contract_no}"

  end

  def brand_name
    product_brand.try(:name)
  end

  def category_cat_id
    product_category.try(:id)
  end

  def category_name
    product_category.try(:name)
  end

  def payment_type
    ticket_contract_payment_type.try(:name)
  end

  def num_of_products
    products.count
  end

  def created_by_user_full_name
    created_by_user.full_name
  end

  def formated_created_at
    created_at.strftime(INOCRM_CONFIG["short_date_format"])
  end

  def formated_accepted_at
    accepted_at.try :strftime, INOCRM_CONFIG["short_date_format"]
  end

  def formated_contract_start_at
    contract_start_at.to_date.try :strftime, INOCRM_CONFIG["short_date_format"]
  end
  def formated_contract_end_at
    contract_end_at.to_date.try :strftime, INOCRM_CONFIG["short_date_format"]
  end

  def dynamic_active
    # !hold.present? and (contract_start_at.to_date .. contract_end_at.to_date+1.day).include?(Date.today)
    !hold.present? and (contract_start_at.to_date .. contract_end_at.to_date).include?(Date.today)
  end
  def discount_less_amount
    contract_products.to_a.sum{|e| e.try(:amount).to_f }
  end
  def product_amount
    contract_products.to_a.sum{|e| e.try(:amount).to_f } - contract_products.to_a.sum{|e| e.try(:discount_amount).to_f }
  end

  def doc_variables
    ContactNumber
    {
      contract_process_date: process_at.try(:strftime, "%d %b %Y"),
      customer_name: organization.name,
      customer_registration_no: organization.account.try(:business_registration_no),
      customer_address_single_line: organization.primary_address.try(:full_name),
      total_contract_amount: amount,
      contract_start_date: contract_start_at.try(:strftime, "%d %b %Y"),
      contract_end_date: contract_end_at.try(:strftime, "%d %b %Y"),
      customer_addr_1: organization.primary_address.try(:address1),
      customer_addr_2: organization.primary_address.try(:address2),
      customer_addr_3: organization.primary_address.try(:address3),
      customer_addr_city: organization.primary_address.try(:city),
      customer_addr_country: organization.primary_address.try(:country).try(:Country),
      contract_number: contract_no_genarate,
      contact_person_name: organization.organization_contact_persons.first.try(:full_name),
      total_amount: "#{ticket_currency.try(:code)} #{product_amount}",
    }
  end

end


class ContractProduct < ActiveRecord::Base
  Product
  self.table_name = "spt_contract_product"
  
  include Tire::Model::Search
  include Tire::Model::Callbacks


  belongs_to :ticket_contract, foreign_key: :contract_id
  belongs_to :product, foreign_key: :product_serial_id
  accepts_nested_attributes_for :product, allow_destroy: true

  belongs_to :sla_time, foreign_key: :sla_id
  belongs_to :installed_location, class_name: "Address"

  accepts_nested_attributes_for :product, allow_destroy: true
  
  mapping do
    indexes :ticket_contract, type: "nested", include_in_parent: true
    indexes :product, type: "nested", include_in_parent: true
  end
  def self.search(params)
    tire.search(page: (params[:page] || 1), per_page: (params[:per_page] || 10)) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          if not params[:report].present?
            puts "not inside report"
            must { range :ticket_contract_contract_start_at, gte: params[:ticket_contract_contract_start_at].to_date.beginning_of_day } if params[:ticket_contract_contract_start_at].present?
            must { range :ticket_contract_contract_end_at, lte: params[:ticket_contract_contract_end_at].to_date.end_of_day } if params[:ticket_contract_contract_end_at].present?
          end
          # must { range :created_at, lte: params[:po_date_to].to_date.end_of_day  } if params[:po_date_to].present?
          # must { range :created_at, gte: params[:po_date_from].to_date.beginning_of_day } if params[:po_date_from].present?
          # must { term :author_id, params[:author_id] } if params[:author_id].present?
          if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present? and params[:report].present?
            puts "inside report"
            must { range :ticket_contract_contract_start_at, lte: params[:ticket_contract_contract_start_at].to_date.beginning_of_day } 
            must { range :ticket_contract_contract_end_at, gte: params[:ticket_contract_contract_end_at].to_date.end_of_day } 
          end


        end
      end
      if params[:sort_by]
        sort { by :ticket_contract_season, {order: "asc", ignore_unmapped: true} }
      else
        sort { by :ticket_contract_created_at, {order: "desc", ignore_unmapped: true} }
      end
    end
  end

  def to_indexed_json
    Organization
    ContactNumber
    Invoice
    Product
    to_json(
      only: [:id, :amount, :discount_amount, :remarks, :installed_location_id, :updated_at],
      methods: [:instral_loc_full_address, :contract_product_engineer_cost, :num_of_tickets, :contract_product_support_engineer_cost, :contract_product_part_cost,:contract_product_additional_cost, :contract_product_external_cost, :ticket_contract_contract_end_at, :ticket_contract_contract_start_at,:ticket_contract_season, :ticket_contract_created_at ],
      include: {
        ticket_contract: {
          only: [ :id, :created_at, :created_by, :customer_id, :products, :contract_no, :hold, :amount, :payment_completed, :contract_start_at,:contract_end_at, :season, :accepted_at, :updated_at],
          methods: [:num_of_products, :brand_name, :category_cat_id, :category_name, :payment_type, :formated_created_at, :created_by_user_full_name, :formated_contract_start_at, :formated_contract_end_at, :dynamic_active, :formated_accepted_at, :product_amount, :discount_less_amount, :contract_no_genarate],
          include: {
            organization: {
              only: [:id, :name, :code, :updated_at],
              methods: [:get_organization_account_manager],
              include: {
                account: {
                  only: [:id, :industry_types_id],
                  methods: [:get_account_manager, :get_account_manager_id],
                  include: {
                    industry_type: {
                      only: [:id, :name, :code],
                    },
                  },
                },
              },
            },
            ticket_contract_type: {
              only: [:id, :name, :contract_no_value],
            },
            ticket_currency: {
              only: [:id, :code],
            },
            owner_organization: {
              only: [:id, :name, :updated_at],
            },
            ticket_contract_payment_type: {
              only: [:id, :name],
            },
            contract_payment_receiveds: {
              only: [:id, :amount, :updated_at],
            },
          },
        },
        product: {
          only: [:id, :serial_no, :name, :updated_at],
        },
      },
    )

  end

  def instral_loc_full_address
    installed_location.try(:full_address)
  end

  def contract_product_tickets
    product.tickets.where(contract_id: self.contract_id)
  end
    def num_of_tickets
    contract_product_tickets.count
  end

  def contract_product_engineer_cost
    contract_product_tickets.to_a.sum { |t| t.ticket_total_cost.try(:engineer_cost).to_f}
  end
  
  def contract_product_support_engineer_cost
    contract_product_tickets.to_a.sum { |t| t.ticket_total_cost.try(:support_engineer_cost).to_f}
  end

  def contract_product_part_cost
    contract_product_tickets.to_a.sum { |t| t.ticket_total_cost.try(:part_cost).to_f}
  end

  def contract_product_additional_cost
    contract_product_tickets.to_a.sum { |t| t.ticket_total_cost.try(:additional_cost).to_f}
  end

  def contract_product_external_cost
    contract_product_tickets.to_a.sum { |t| t.ticket_total_cost.try(:external_cost).to_f}
  end
  def ticket_contract_contract_end_at
    ticket_contract.contract_end_at
  end

  def ticket_contract_contract_start_at
    ticket_contract.contract_start_at
  end
  def ticket_contract_season
    ticket_contract.season
  end
  def ticket_contract_created_at
    ticket_contract.created_at
  end
end

class ContractStatus < ActiveRecord::Base
  self.table_name = "mst_spt_contract_status"
  has_many :ticket_contracts, foreign_key: :status_id
end

class TicketStatus < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_status"

  has_many :tickets, foreign_key: :status_id

  validates_presence_of [:code, :name]
end

class TicketCurrency < ActiveRecord::Base
  self.table_name = "mst_currency"

  has_many :tickets, foreign_key: :base_currency_id

  validates_presence_of [:currency, :code, :symbol]
  validates_inclusion_of :base_currency, in: [true, false]
end

class TicketPaymentReceivedType < ActiveRecord::Base
  self.table_name = "mst_spt_payment_received_type"

  has_many :ticket_payment_receiveds, foreign_key: :type_id

  TYPES = {"cash" => 1, "cheque" => 2, "credit card" => 3, "other" => 4}
end

class TicketContractPaymentType  < ActiveRecord::Base
  self.table_name = "mst_spt_contract_payment_type"

end

class TicketProductSerial < ActiveRecord::Base
  self.table_name = "spt_ticket_product_serial"

  belongs_to :ticket, foreign_key: :ticket_id
  belongs_to :product, foreign_key: :product_serial_id

  belongs_to :ref_product_serial, class_name: "Product"
end

class TicketAccessory < ActiveRecord::Base
  self.table_name = "spt_ticket_accessory"

  belongs_to :accessory
  belongs_to :ticket
end

class JointTicket < ActiveRecord::Base
  self.table_name = "spt_joint_ticket"

  belongs_to :ticket
end

class ExtraRemark < ActiveRecord::Base
  self.table_name = "mst_spt_extra_remark"

  has_many :ticket_extra_remarks, foreign_key: :extra_remark_id
  has_many :tickets, through: :ticket_extra_remarks
end

class TicketExtraRemark < ActiveRecord::Base
  self.table_name = "spt_ticket_extra_remark"

  belongs_to :ticket, foreign_key: :ticket_id
  belongs_to :extra_remark, foreign_key: :extra_remark_id
end

class TicketWorkflowProcess < ActiveRecord::Base
  self.table_name = "spt_ticket_workflow_process"

  belongs_to :ticket
end

class TicketStatusResolve < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_status_resolve"

  has_many :tickets, foreign_key: :status_resolve_id

end

class PrintTemplate < ActiveRecord::Base
  self.table_name = "mst_spt_templates"

  # has_many :tickets, foreign_key: :status_resolve_id

end

class TicketStartAction < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_start_action"

  validates :action, presence: true, uniqueness: true
  has_many :tickets, foreign_key: :job_started_action_id
  accepts_nested_attributes_for :tickets, allow_destroy: true

  def is_used_anywhere?
    tickets.any?
  end

end

class TicketRepairType < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_repair_type"

  has_many :tickets, foreign_key: :job_started_action_id
  accepts_nested_attributes_for :tickets, allow_destroy: true

  has_many :action_warranty_repair_types, foreign_key: :ticket_repair_type_id

end

class Reason < ActiveRecord::Base
  self.table_name = "mst_spt_reason"

  validates :reason, presence: true, uniqueness: true

  has_many :tickets, foreign_key: :hold_reason_id
  accepts_nested_attributes_for :tickets, allow_destroy: true

  has_many :ticket_re_assign_requests
  accepts_nested_attributes_for :ticket_re_assign_requests, allow_destroy: true

  has_many :ticket_terminate_jobs
  accepts_nested_attributes_for :ticket_terminate_jobs, allow_destroy: true

  has_many :act_holds
  accepts_nested_attributes_for :act_holds, allow_destroy: true

  has_many :unused_reasons, class_name: "TicketSparePart", foreign_key: :unused_reason_id
  accepts_nested_attributes_for :unused_reasons, allow_destroy: true

  has_many :part_terminated_reasons, class_name: "TicketSparePart", foreign_key: :part_terminated_reason_id
  accepts_nested_attributes_for :part_terminated_reasons, allow_destroy: true

  has_many :return_part_damage_reasons, class_name: "TicketSparePartStore", foreign_key: :return_part_damage_reason_id
  accepts_nested_attributes_for :return_part_damage_reasons, allow_destroy: true

  # has_many :onloan_return_part_damage_reasons, class_name: "TicketOnLoanSparePart"#, foreign_key: :part_terminated_reason_id
  # accepts_nested_attributes_for :return_part_damage_reasons, allow_destroy: true

  has_many :on_loan_unused_reasons, class_name: "TicketOnLoanSparePart", foreign_key: :unused_reason_id
  accepts_nested_attributes_for :on_loan_unused_reasons, allow_destroy: true

  has_many :on_loan_part_terminated_reasons, class_name: "TicketOnLoanSparePart", foreign_key: :part_terminated_reason_id
  accepts_nested_attributes_for :on_loan_part_terminated_reasons, allow_destroy: true

  has_many :reject_return_part_reasons, class_name: "RequestSparePart", foreign_key: :reject_return_part_reason_id
  accepts_nested_attributes_for :reject_return_part_reasons, allow_destroy: true

  has_many :action_warranty_extends, foreign_key: :reject_reason_id
  accepts_nested_attributes_for :action_warranty_extends, allow_destroy: true

  has_many :act_terminate_job_payments, foreign_key: :adjust_reason_id

  has_many :act_ticket_close_approves, class_name: "ActTicketCloseApprove", foreign_key: :reject_reason_id

  def is_used_anywhere?
    TaskAction
    TicketSparePart
    Warranty

    tickets.any? or ticket_re_assign_requests.any? or ticket_terminate_jobs.any? or act_holds.any? or unused_reasons.any? or part_terminated_reasons.any? or on_loan_unused_reasons.any? or reject_return_part_reasons.any? or act_terminate_job_payments.any? or action_warranty_extends.any? or act_ticket_close_approves.any? or return_part_damage_reasons.any?
     # or onloan_return_part_damage_reasons.any?

    # tickets.any? or ticket_re_assign_requests.any? or ticket_terminate_jobs.any? or act_holds.any? or unused_reasons.any? or part_terminated_reasons.any? or return_part_damage_reasons.any? or on_loan_unused_reasons.any? or on_loan_part_terminated_reasons.any? or reject_return_part_reasons.any? or action_warranty_extends.any? or act_terminate_job_payments.any? or act_ticket_close_approves.any?
  end
end

class TicketReAssignRequest < ActiveRecord::Base
  self.table_name = "spt_act_re_assign_request"

  belongs_to :reason
  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

end

class TicketTotalCost < ActiveRecord::Base
  self.table_name = "spt_ticket_total_cost"

  belongs_to :ticket

end