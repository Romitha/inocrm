class ReportsController < ApplicationController
  # layout "report_pdf"

  def quotation
    # https://github.com/mileszs/wicked_pdf

    Invoice
    ContactNumber
    Tax
    Inventory

    quotation = CustomerQuotation.find params[:quotation_id]

    ticket = quotation.ticket

    product = ticket.products.first

    quotation_no = quotation.customer_quotation_no.to_s.rjust(6, INOCRM_CONFIG['quotation_no_format'])

    product_brand = product.product_brand.name

    model_no = product.model_no

    serial_no = product.serial_no

    product_no = product.product_no

    company_name = ticket.customer.try(:name)

    address1 = ticket.customer.address1
    address2 = ticket.customer.address2
    address3 = ticket.customer.address3
    address4 = ticket.customer.address4

    ticket_ref = ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])

    ticket_date = ticket.created_at.strftime(INOCRM_CONFIG['long_date_format'])

    ticket_time = ticket.created_at.strftime(INOCRM_CONFIG['time_format'])

    validity_period = quotation.validity_period

    delivery_period = quotation.delivery_period
    quotation_note = quotation.note
    canceled = quotation.canceled

    print_organization_bank = quotation.organization_bank_detail.try(:bank_name)
    print_organization_bank_acc_no = quotation.organization_bank_detail.try(:account_no)
    print_organization_bank_address = quotation.organization_bank_detail.try(:bank_address)
    print_organization_bank_swift_code = quotation.organization_bank_detail.try(:swift_code)

    if quotation.print_exchange_rate.present?
      exchange_rate = quotation.print_exchange_rate.to_f
    else
      exchange_rate = 1
    end
    row_count = 0
    total_amount = 0
    total_advance_amount = 0
    currency = (quotation.print_currency.try(:code) || quotation.currency.try(:code))
    payment_term = quotation.payment_term.try(:name)
    warranty = quotation.warranty
    created_by = User.cached_find_by_id(quotation.created_by).try(:full_name)

    repeat_data = []

    quotation.customer_quotation_estimations.each do |ticket_quotation_estimation|
      ticket_estimation = ticket_quotation_estimation.ticket_estimation

      total_advance_amount += ticket_estimation.approval_required ? ticket_estimation.approved_adv_pmnt_amount.to_f : ticket_estimation.advance_payment_amount.to_f
      if quotation.print_currency.try(:code) != quotation.currency.try(:code)
        total_advance_amount *= exchange_rate
      end
      ticket_estimation.ticket_estimation_externals.each do |estimation_external|
        unit_price = ticket_estimation.approval_required ? estimation_external.approved_estimated_price.to_f : estimation_external.estimated_price.to_f
        if quotation.print_currency.try(:code) != quotation.currency.try(:code)
          unit_price *= exchange_rate
        end
        repeat_data_hash = {}

        row_count += 1
        repeat_data_hash[:item_index] = row_count
        # repeat_data_hash[:item_code] = index
        repeat_data_hash[:description] = "#{estimation_external.description}" + "#{' (Warr: ' + estimation_external.warranty_period.to_s + ' M)' if estimation_external.warranty_period.present? }"
        repeat_data_hash[:quantity] = 1
        repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
        repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)

        total_amount += unit_price

        repeat_data_hash[:currency] = (quotation.print_currency.try(:code) || ticket_estimation.currency.code)

        repeat_data << repeat_data_hash

        estimation_external.ticket_estimation_external_taxes.each do |ticket_estimation_external_tax|
          repeat_data_hash = {}

          unit_price = ticket_estimation.approval_required ? ticket_estimation_external_tax.approved_tax_amount.to_f : ticket_estimation_external_tax.estimated_tax_amount.to_f
          if quotation.print_currency.try(:code) != quotation.currency.try(:code)
            unit_price *= exchange_rate
          end
          row_count += 1
          repeat_data_hash[:item_index] = row_count
          # repeat_data_hash[:item_code] = index
          repeat_data_hash[:description] = "#{ticket_estimation_external_tax.tax.tax} (#{ticket_estimation_external_tax.tax_rate})"
          # repeat_data_hash[:quantity] = 1
          # repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
          repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)

          total_amount += unit_price

          repeat_data_hash[:currency] = (quotation.print_currency.try(:code) || ticket_estimation.currency.code)

          repeat_data << repeat_data_hash

        end

      end

      ticket_estimation.ticket_estimation_parts.each do |estimation_part|
        total_price = ticket_estimation.approval_required ? estimation_part.approved_estimated_price.to_f : estimation_part.estimated_price.to_f

        quantity = ( ( estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock ).try(:approved_quantity) or ( estimation_part.ticket_spare_part.ticket_spare_part_manufacture or estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock ).try(:requested_quantity) )

        unit_price = (quantity and quantity.to_f != 0) ? total_price/quantity.to_f : 0
          if quotation.print_currency.try(:code) != quotation.currency.try(:code)
          unit_price *= exchange_rate
          total_price *= exchange_rate
        end
        repeat_data_hash = {}

        row_count += 1
        repeat_data_hash[:item_index] = row_count
        # repeat_data_hash[:item_code] = index
        repeat_data_hash[:item_code] = estimation_part.ticket_spare_part.ticket_spare_part_store.present? ? (estimation_part.ticket_spare_part.ticket_spare_part_store.approved_inventory_product.try(:generated_item_code) or estimation_part.ticket_spare_part.ticket_spare_part_store.inventory_product.try(:generated_item_code)) : ""

        repeat_data_hash[:description] = "Part No: #{estimation_part.ticket_spare_part.spare_part_no} #{estimation_part.ticket_spare_part.spare_part_description}" + "#{' (Warr: ' + estimation_part.warranty_period.to_s + ' M)' if estimation_part.warranty_period.present? }"

        repeat_data_hash[:quantity] = quantity
        repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
        repeat_data_hash[:totalprice] = view_context.standard_currency_format(total_price)

        total_amount += total_price

        repeat_data_hash[:currency] = (quotation.print_currency.try(:code) || ticket_estimation.currency.code)

        repeat_data << repeat_data_hash

        estimation_part.ticket_estimation_part_taxes.each do |ticket_estimation_part_tax|

          unit_price = ticket_estimation.approval_required ? ticket_estimation_part_tax.approved_tax_amount.to_f : ticket_estimation_part_tax.estimated_tax_amount.to_f
          if quotation.print_currency.try(:code) != quotation.currency.try(:code)
            unit_price *= exchange_rate
          end
          repeat_data_hash = {}

          row_count += 1
          repeat_data_hash[:item_index] = row_count
          # repeat_data_hash[:item_code] = index
          repeat_data_hash[:description] = "#{ticket_estimation_part_tax.tax.tax} (#{ticket_estimation_part_tax.tax_rate})"

          # repeat_data_hash[:quantity] = quantity
          # repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
          repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)

          total_amount += unit_price

          repeat_data_hash[:currency] = (quotation.print_currency.try(:code) || ticket_estimation.currency.code)

          repeat_data << repeat_data_hash

        end

      end

      ticket_estimation.ticket_estimation_additionals.each do |ticket_estimation_additional|
        repeat_data_hash = {}

        unit_price = ticket_estimation.approval_required ? ticket_estimation_additional.approved_estimated_price.to_f : ticket_estimation_additional.estimated_price.to_f
        if quotation.print_currency.try(:code) != quotation.currency.try(:code)
          unit_price *= exchange_rate
        end
        row_count += 1
        repeat_data_hash[:item_index] = row_count

        repeat_data_hash[:description] = ticket_estimation_additional.additional_charge.additional_charge
        repeat_data_hash[:quantity] = 1
        repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)

        repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)
        total_amount += unit_price

        repeat_data_hash[:currency] = (quotation.print_currency.try(:code) || ticket_estimation.currency.code)

        repeat_data << repeat_data_hash

        ticket_estimation_additional.ticket_estimation_additional_taxes.each do |ticket_estimation_additional_tax|
          repeat_data_hash = {}

          unit_price = ticket_estimation.approval_required ? ticket_estimation_additional_tax.approved_tax_amount.to_f : ticket_estimation_additional_tax.estimated_tax_amount.to_f
          if quotation.print_currency.try(:code) != quotation.currency.try(:code)
            unit_price *= exchange_rate
          end
          row_count += 1
          repeat_data_hash[:item_index] = row_count

          repeat_data_hash[:description] = "#{ticket_estimation_additional_tax.tax.tax} (#{ticket_estimation_additional_tax.tax_rate})"

          repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)
          total_amount += unit_price

          repeat_data_hash[:currency] = (quotation.print_currency.try(:code) || ticket_estimation.currency.code)

          repeat_data << repeat_data_hash
        end

      end

    end

    owner = (quotation.organization || Organization.owner)

    @print_object = {
      owner: {
        name: owner.name,
        logo: owner.logo.url,
        address: (owner.addresses.primary_address.first and owner.addresses.primary_address.first.full_address),
        website: owner.web_site,
        contactDetails: owner.contact_numbers.map { |c| {category: c.organization_contact_type.try(:name), value: c.value } },
        vat_num: owner.account.try(:vat_number),
      },

      duplicate_d: "#{'D' if ticket.ticket_complete_print_count > 0}",
      canceled: canceled,
      quotation_no: quotation_no,
      product_brand: product_brand,
      model_no: model_no,
      serial_no: serial_no,
      product_no: product_no,
      company_name: company_name,
      address1: address1,
      address2: address2,
      address3: address3,
      address4: address4,
      ticket_ref: ticket_ref,
      created_date: ticket_date,
      created_time: ticket_time,
      validity_period: validity_period,
      delivery_period: delivery_period,
      repeat_data: repeat_data,
      currency: currency,
      payment_term: payment_term,
      warranty: warranty,
      note: quotation_note,
      created_by: created_by,
      print_organization_bank: print_organization_bank,
      print_organization_bank_acc_no: print_organization_bank_acc_no,
      print_organization_bank_address: print_organization_bank_address,
      print_organization_bank_swift_code: print_organization_bank_swift_code,

      row_count: row_count,
      total_amount: view_context.standard_currency_format(total_amount),
      total_advance_amount: view_context.standard_currency_format(total_advance_amount),

    }

    @print_hash_to_object = HashToObject.new @print_object

    render_template = case INOCRM_CONFIG['spt_part_quotation_pdf']

    when "bobbin"
      "quotation_bobbin"
    else
      "quotation"
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{quotation_no} - #{company_name}",
          margin:  {
            top:               10,                     # default 10 (mm)
            bottom:            10,
            left:              15,
            right:             10
          },
          disable_javascript: false,
          layout: "report_pdf",
          template: render_template
      end
    end

  end

  # before_filter :change_format
  def contract_ticket_report
    Ticket
    Invoice
    if params[:search].present?
      params[:from_where] = "job_ticket"

      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
      params[:per_page] = 100
      params[:sort_by] = true
      params[:query] = refined_search

      # @customer_name = Organization.find_by_id(params[:search_contracts]["ticket_contract.organization.id"]).try(:name)
      # @service_provider = Organization.find_by_id(params[:search_contracts]["ticket_contract.owner_organization.id"]).try(:name)
      # @account_manager = params[:search_contracts]["ticket_contract.organization.account.get_account_manager"]
      # @season = params[:search_contracts]["ticket_contract.season"]
      # @date_from = params[:ticket_contract_contract_start_at]
      # @date_to = params[:ticket_contract_contract_end_at]
      # @brand_name = params[:search_contracts]["ticket_contract.brand_name"]
      # @category_name = ProductCategory.find_by_id(params[:search_contracts]["ticket_contract.category_cat_id"]).try(:name)
      # @contract_type = TicketContractType.find_by_id(params[:search_contracts]["ticket_contract.ticket_contract_type.id"]).try(:name)
      # @currnecy = TicketCurrency.find_by_id(params[:search_contracts]["ticket_contract.ticket_currency.id"]).try(:code)
      after_contract_products = []
      before_contract_products = Ticket.search(params)
      if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present?
        params[:report] = true
        after_contract_products = Ticket.search(params)
        @tickets = (before_contract_products.results + after_contract_products.results).uniq{ |r| r.id }
      else
        @tickets = before_contract_products.results
      end

      not_need_index = []

      @tickets.each do |ticket|
        need_index_boolean = ((ticket.owner_engineer.try(:updated_at).try(:to_datetime) == TicketEngineer.find_by_id(ticket.owner_engineer.try(:id)).try(:updated_at).try(:to_datetime)) and ( ticket.updated_at.to_datetime == Ticket.find(ticket.id).updated_at.to_datetime ) and ( ticket.ticket_contract.try(:updated_at).try(:to_datetime) == TicketContract.find_by_id(ticket.ticket_contract.try(:id)).try(:updated_at).try(:to_datetime)) and ( ticket.ticket_contract.try(:organization).try(:updated_at).try(:to_datetime) == Organization.find_by_id(ticket.ticket_contract.try(:organization).try(:id)).try(:updated_at).try(:to_datetime) ) and ( ticket.ticket_contract.try(:owner_organization).try(:updated_at).try(:to_datetime) == Organization.find_by_id(ticket.ticket_contract.try(:owner_organization).try(:id)).try(:updated_at).try(:to_datetime)) and ( ticket.product.try(:updated_at).try(:to_datetime) == Product.find_by_id(ticket.product.try(:id)).try(:updated_at).try(:to_datetime) ) )


        not_need_index << {id: ticket.id, not_need_index: need_index_boolean} unless need_index_boolean
      end

      if @tickets.present?
        t_ids = []
        not_need_index.uniq{|n| n[:id]}.each do |n_index|
          t_ids << n_index[:id]
          # if !n_index[:not_need_index]
          #   # Ticket.find(n_index[:id]).update_index
          # end
        end

        Ticket.index.import Ticket.where(id: t_ids) if t_ids.present?

      end

    end

    respond_to do |format|
      if params[:search].present?
        sleep 3
        after_contract_products = []
        params[:report] = nil
        before_contract_products = Ticket.search(params)
        @tickets = if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present?
          params[:report] = true
          after_contract_products = Ticket.search(params)
          (before_contract_products.results + after_contract_products.results).uniq{|r| r.id}
        else
          before_contract_products.results
        end
        format.xls
      else
        format.html
      end
    end
  end
  def non_contract_ticket_report
    Ticket
    Invoice
    if params[:search].present?
      params[:from_where] = "job_ticket"

      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
      params[:per_page] = 100
      params[:sort_by] = true
      params[:query] = refined_search
      params[:non_report] = true
      # @customer_name = Organization.find_by_id(params[:search_contracts]["ticket_contract.organization.id"]).try(:name)
      # @service_provider = Organization.find_by_id(params[:search_contracts]["ticket_contract.owner_organization.id"]).try(:name)
      # @account_manager = params[:search_contracts]["ticket_contract.organization.account.get_account_manager"]
      # @season = params[:search_contracts]["ticket_contract.season"]
      # @date_from = params[:ticket_contract_contract_start_at]
      # @date_to = params[:ticket_contract_contract_end_at]
      # @brand_name = params[:search_contracts]["ticket_contract.brand_name"]
      # @category_name = ProductCategory.find_by_id(params[:search_contracts]["ticket_contract.category_cat_id"]).try(:name)
      # @contract_type = TicketContractType.find_by_id(params[:search_contracts]["ticket_contract.ticket_contract_type.id"]).try(:name)
      # @currnecy = TicketCurrency.find_by_id(params[:search_contracts]["ticket_contract.ticket_currency.id"]).try(:code)
      after_contract_products = []
      before_contract_products = Ticket.search(params)
      if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present?
        params[:report] = true
        after_contract_products = Ticket.search(params)
        @tickets = (before_contract_products.results + after_contract_products.results).uniq{ |r| r.id }
      else
        @tickets = before_contract_products.results
      end

      not_need_index = []

      @tickets.each do |ticket|
        need_index_boolean = ((ticket.owner_engineer.try(:updated_at).try(:to_datetime) == TicketEngineer.find_by_id(ticket.owner_engineer.try(:id)).try(:updated_at).try(:to_datetime)) and ( ticket.updated_at.to_datetime == Ticket.find(ticket.id).updated_at.to_datetime ) and ( ticket.ticket_contract.try(:updated_at).try(:to_datetime) == TicketContract.find_by_id(ticket.ticket_contract.try(:id)).try(:updated_at).try(:to_datetime)) and ( ticket.ticket_contract.try(:organization).try(:updated_at).try(:to_datetime) == Organization.find_by_id(ticket.ticket_contract.try(:organization).try(:id)).try(:updated_at).try(:to_datetime) ) and ( ticket.ticket_contract.try(:owner_organization).try(:updated_at).try(:to_datetime) == Organization.find_by_id(ticket.ticket_contract.try(:owner_organization).try(:id)).try(:updated_at).try(:to_datetime)) and ( ticket.product.try(:updated_at).try(:to_datetime) == Product.find_by_id(ticket.product.try(:id)).try(:updated_at).try(:to_datetime) ) )
        not_need_index << {id: ticket.id, not_need_index: need_index_boolean} unless need_index_boolean
      end

      if @tickets.present?
        t_ids = []
        not_need_index.uniq{|n| n[:id]}.each do |n_index|
          t_ids << n_index[:id]
          # if !n_index[:not_need_index]
          #   # Ticket.find(n_index[:id]).update_index
          # end
        end
        Ticket.index.import Ticket.where(id: t_ids) if t_ids.present?
      end

    end

    respond_to do |format|
      if params[:search].present?
        sleep 3
        after_contract_products = []
        params[:report] = nil
        before_contract_products = Ticket.search(params)
        @tickets = if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present?
          params[:report] = true
          after_contract_products = Ticket.search(params)
          (before_contract_products.results + after_contract_products.results).uniq{|r| r.id}
        else
          before_contract_products.results
        end
        format.xls
      else
        format.html
      end
    end
  end

  def customer_product_report
    Ticket
    Invoice
    if params[:search].present?
      params[:from_where] = "customer_product"

      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
      params[:query] = refined_search

      after_contract_products = []
      before_contract_products = Product.search(params)

      @products = before_contract_products.results

      not_need_index = []

      @products.each do |product|
        need_index_boolean = (product.updated_at.to_datetime == Product.find(product.id).updated_at.to_datetime)
        not_need_index << {id: product.id, not_need_index: need_index_boolean} unless need_index_boolean
      end

      if @products.present?
        t_ids = []
        not_need_index.uniq{|n| n[:id]}.each do |n_index|
          t_ids << n_index[:id]
          # if !n_index[:not_need_index]
          #   # Ticket.find(n_index[:id]).update_index
          # end
        end
        Product.index.import Product.where(id: t_ids) if t_ids.present?
      end
    end
    respond_to do |format|
      if params[:search].present?
        format.xls
      else
        format.html
      end
    end
  end

  def contract_cost_analys_report
    Ticket
    Invoice
    if params[:search].present?
      # params[:from_where] = "excel_output"

      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
    end
    params[:per_page] = 100
    params[:sort_by] = true
    params[:query] = refined_search
    after_contract_products = []
    before_contract_products = ContractProduct.search(params)
    if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present?
      params[:report] = true
      after_contract_products = ContractProduct.search(params)
      @contract_products = (before_contract_products.results + after_contract_products.results).uniq{|r| r.id}
    else
      @contract_products = before_contract_products.results
    end



    not_need_index = []

    @contract_products.each do |contract_product|

      need_index_boolean = (( contract_product.ticket_contract.updated_at.to_datetime == TicketContract.find(contract_product.ticket_contract.id).updated_at.to_datetime ) and ( contract_product.updated_at.to_datetime == ContractProduct.find(contract_product.id).updated_at.to_datetime ) and ( contract_product.ticket_contract.organization.updated_at.to_datetime == Organization.find(contract_product.ticket_contract.organization.id).updated_at.to_datetime ) and ( contract_product.ticket_contract.owner_organization.updated_at.to_datetime == Organization.find(contract_product.ticket_contract.owner_organization.id).updated_at.to_datetime ) and ( contract_product.product.try(:updated_at).try(:to_datetime) == Product.find_by_id(contract_product.product.try(:id)).try(:updated_at).try(:to_datetime)))

      not_need_index << {id: contract_product.id, not_need_index: need_index_boolean}

    end

    if @contract_products.present?
      not_need_index.uniq{|n| n[:id]}.each do |n_index|
        if !n_index[:not_need_index]
          ContractProduct.find(n_index[:id]).update_index
        end
      end
    end

    respond_to do |format|
      if params[:search].present?
        format.xls
      else
        format.html
      end
    end
  end

  def contract_report
    Ticket
    Invoice
    authorize! :contract_report, TicketContract

    if params[:search].present?

      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
    end
    params[:per_page] = 100
    params[:sort_by] = true
    params[:query] = refined_search

    after_contract_products = []
    before_contract_products = TicketContract.search(params)
    if params[:contract_date_from].present? and params[:contract_date_to].present?
      params[:report] = true
      after_contract_products = TicketContract.search(params)
      @contracts = (before_contract_products.results + after_contract_products.results).uniq{|r| r.id}
    else
      @contracts = before_contract_products.results
    end

    not_need_index = []
    @contracts.each do |contract|

      need_index_boolean = (( contract.organization.updated_at.to_datetime == Organization.find(contract.organization.id).updated_at.to_datetime ) and ( contract.owner_organization.updated_at.to_datetime == Organization.find(contract.owner_organization.id).updated_at.to_datetime ) and ( contract.product.try(:updated_at).try(:to_datetime) == Product.find_by_id(contract.product.try(:id)).try(:updated_at).try(:to_datetime) ) )

      not_need_index << {id: contract.id, not_need_index: need_index_boolean}

    end

    if @contracts.present?

      not_need_index.uniq{|n| n[:id]}.each do |n_index|
        if !n_index[:not_need_index]
          TicketContract.find(n_index[:id]).update_index
        end
      end

    end

    respond_to do |format|
      if params[:search].present?
        format.xls
      else
        format.html
      end
    end
  end
  

  def summery
    Ticket
    Invoice
    if params[:search].present?
      # params[:from_where] = "excel_output"

      refined_contract = (params[:search_contracts] || {}).map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
    end
    params[:per_page] = 100
    params[:sort_by] = true
    params[:query] = refined_search


    params[:report_summery] = true
    @contracts = TicketContract.search(params)

    not_need_index = []
    @contracts.each do |contract|

      need_index_boolean = (( contract.organization.updated_at.to_datetime == Organization.find(contract.organization.id).updated_at.to_datetime ) and ( contract.owner_organization.updated_at.to_datetime == Organization.find(contract.owner_organization.id).updated_at.to_datetime ) and ( contract.product.try(:updated_at).try(:to_datetime) == Product.find_by_id(contract.product.try(:id)).try(:updated_at).try(:to_datetime) ) )

      not_need_index << {id: contract.id, not_need_index: need_index_boolean}

    end
    if @contracts.present?

      not_need_index.uniq{|n| n[:id]}.each do |n_index|
        if !n_index[:not_need_index]
          TicketContract.find(n_index[:id]).update_index
        end
      end

    end
    respond_to do |format|
      if params[:search].present?
        format.xls
      else
        format.html
      end
    end
  end
  def excel_output
    Ticket
    User
    Organization
    Address
    ContactNumber
    Product
    SlaTime
    TaskAction
    Invoice
    Inventory
    TicketSparePart


    refined_search_ticket = nil
    if params[:search].present?
      params[:from_where] = "excel_output"
      # refined_search_ticket = "logged_at:[#{params[:l_range_from].present? ? params[:l_range_from] : (Date.today - 3.months) } TO #{params[:l_range_to].present? ? params[:l_range_to] : Date.today }]"

      search_ticket = params[:search_ticket]
      search_ticket["cus_chargeable"] = search_ticket["cus_chargeable"].present?.to_s
      refined_search_ticket = ([refined_search_ticket] + search_ticket.map { |k, v| "#{k}:#{v}" if v.present? }).compact.join(" AND ")

      # refined_search_ticket = [refined_search_ticket, "logged_at:[#{params[:l_range_from].present? ? params[:l_range_from] : (Date.today - 3.months) } TO #{params[:l_range_to].present? ? params[:l_range_to] : Date.today }]"]
      # refined_search_ticket << " AND logged_at:[* TO #{Date.today}]"

      # puts "*************"
      # puts refined_search_ticket
      # puts "*************"


      request.format = "xls"
    end
    params[:per_page] = 100
    params[:query] = refined_search_ticket
    @ticket = Ticket.search(params)

    # @ticket = Ticket.all
    # @ticket = Ticket.search()
    respond_to do |format|
      if params[:search].present?
        format.xls
      else
        format.html
      end
    end
  end

  def po_output
    Inventory
    Invoice
    ContactNumber
    # https://github.com/mileszs/wicked_pdf

    po = InventoryPo.find params[:po_id]

    customer = {
      contactPerson: (po.supplier.organization_contact_persons.first and po.supplier.organization_contact_persons.first.full_name),
      name: po.supplier.name,
      address: (po.supplier.addresses.primary_address.first and po.supplier.addresses.primary_address.first.full_address),
    }

    created_date = po.created_at.strftime(INOCRM_CONFIG['long_date_format'])
    quotation_no = po.quotation_no
    delivery_mode = po.delivery_mode
    required_date = po.delivery_date_text

    po_item_tax_total = po.inventory_po_items.to_a.sum{|e| e.inventory_po_item_taxes.sum(:amount)}

    po_taxes = po.inventory_po_items.to_a.sum{|e| e.inventory_po_item_taxes}.map do |po_tax|
      {
        amount: po_tax.amount.to_f,
        tax_type: po_tax.tax.tax,
      }
    end

    poItems = po.inventory_po_items.map do |po_item|
      {
        itemCode: po_item.inventory_prn_item.inventory_product.generated_item_code,
        remarks: po_item.remarks,
        description: po_item.description,
        quantity: po_item.quantity,
        unitPrice: view_context.standard_currency_format(po_item.unit_cost),
        total: (po_item.unit_cost * po_item.quantity),
      }

    end

    sub_total = poItems.inject(0){|i, k| i+k[:total].to_f }

    owner = Organization.owner

    @print_object = {
      owner: {
        name: owner.name,
        logo: owner.logo.url,
        address: (owner.addresses.primary_address.first and owner.addresses.primary_address.first.full_address),
        website: owner.web_site,
        contactDetails: owner.contact_numbers.map { |c| {category: c.organization_contact_type.try(:name), value: c.value } },
      },

      customer: customer,
      poNo: po.formated_po_no,
      deliveryDate: po.delivery_date.try(:strftime, "%Y-%m-%d"),
      ourRef: po.your_ref,
      quotation: quotation_no,
      dateRequired: required_date,
      paymentTerm: po.payment_term.name,
      deliveryMode: delivery_mode,

      poItems: poItems,

      subTotal: sub_total,
      discount: po.discount_amount,
      total: ( sub_total + po_item_tax_total - po.discount_amount ),
      poTaxes: po_taxes,
      createdDate: created_date,
    }

    @print_hash_to_object = HashToObject.new @print_object


    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name",
          margin:  {
            top:               10,                     # default 10 (mm)
            bottom:            10,
            left:              15,
            right:             10
          },
          disable_javascript: false,
          layout: "report_pdf"
      end
    end
  end
end
