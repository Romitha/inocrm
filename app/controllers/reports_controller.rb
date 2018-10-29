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

    cus_contact_person = ticket.send("contact_person#{ticket.inform_cp}").full_name
    
    cus_contact_info = ticket.send("contact_person#{ticket.inform_cp}").contact_person_contact_types.map(&:contact_info).join(", ")

    vat_no  = ticket.customer.vat_no

    svat_no = ticket.customer.svat_no

    ticket_ref = ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])

    ticket_date = ticket.created_at.strftime(INOCRM_CONFIG['long_date_format'])

    ticket_time = ticket.created_at.strftime(INOCRM_CONFIG['time_format'])

    quotation_date = quotation.created_at_to.strftime(INOCRM_CONFIG['long_date_format'])

    quotation_time = quotation.created_at.strftime(INOCRM_CONFIG['time_format'])

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
      cus_contact_person: cus_contact_person,
      cus_contact_info: cus_contact_info,
      vat_no: vat_no,
      svat_no: svat_no,
      ticket_ref: ticket_ref,
      created_date: quotation_date,
      created_time: quotation_time,
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
      "reports/quotation_bobbin"
    else
      "reports/quotation"
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



  def customer_supplier_report

    Organization

    customer_report = []
    refined_query = ""
    if params[:search].present? or params[:excel_report].present?
      customer_report = params[:search_customer_supplier].map { |k, v| "#{k}:#{v}" if v.present? }.compact
    end

    refined_query += customer_report.join(" AND ")

    params[:query] = refined_query

    @customer_reports = Organization.search(params)

    @account_managers = User.where(active: true)

  end



  def non_contract_ticket_report
    Ticket
    Invoice
    authorize! :non_contract_ticket_report, Ticket
    if params[:search].present?
      params[:from_where] = "job_ticket"

      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
      params[:per_page] = 100
      params[:sort_by] = true
      params[:query] = refined_search
      params[:non_report] = true
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
    Organization
    authorize! :customer_product_report, Product
    if params[:search].present?
      params[:from_where] = "customer_product"

      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

      request.format = "xls"
      params[:query] = refined_search

      after_contract_products = []
      @products = Product.search(params)

      # @products = before_contract_products.results

      not_need_index = []

      @products.each do |product|
        database_product = Product.find_by_id(product.id)
        need_index_boolean = (database_product.present? and (product.updated_at.to_datetime == database_product.updated_at.to_datetime))
        not_need_index << {id: product.id, not_need_index: need_index_boolean} unless need_index_boolean
      end

      if @products.present?
        t_ids = []
        not_need_index.uniq{|n| n[:id]}.each do |n_index|
          t_ids << n_index[:id]
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

    organization_ids_query = ""

    if params[:search].present?

      refined_contract = params[:search_contracts]#.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      if params[:decendent_customer].present?
        organization = Organization.find(refined_contract["organization.id"])
        decendent_ids = organization.anchestors.map{|m| m[:member]}.uniq{|m| m.id}.collect{|org| org.id}
        organization_ids_query = "(#{decendent_ids.join(' ')})"
        refined_contract["organization.id"] = organization_ids_query

      end

      refined_contract = refined_contract.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

      refined_search = [refined_contract].map{|v| v if v.present? }.compact.join(" AND ")

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

      need_index_boolean = (( contract.updated_at.to_datetime == TicketContract.find(contract.id).updated_at.to_datetime ) and ( contract.organization.updated_at.to_datetime == Organization.find(contract.organization.id).updated_at.to_datetime ) and ( contract.owner_organization.updated_at.to_datetime == Organization.find(contract.owner_organization.id).updated_at.to_datetime ) and ( contract.product.try(:updated_at).try(:to_datetime) == Product.find_by_id(contract.product.try(:id)).try(:updated_at).try(:to_datetime) ) )

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
        sleep 3
        after_contract_products = []
        params[:report] = nil
        before_contract_products = TicketContract.search(params)
        @warranties = if params[:contract_date_from].present? and params[:contract_date_to].present?
          params[:report] = true
          after_contract_products = TicketContract.search(params)
          (before_contract_products.results + after_contract_products.results).uniq{|r| r.id}
        else
          before_contract_products.results
        end
        format.xls
      else
        format.html
      end
    end
    # TicketContract.index.import TicketContract.all
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
    @given_date = params[:contract_date_from]

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
    # TicketContract.index.import TicketContract.all
  end

  def warranty_expire
    Ticket
    Invoice
    authorize! :warranty_expire_report, Warranty
    if params[:date_from].present?
      @warranty_expired_list = Warranty.all.select{|w| w.end_at.to_date < params[:date_from].to_date.beginning_of_day}
      @warranty_expireds = @warranty_expired_list.sort_by{|e| e[:end_at]}.reverse
    end
    if params[:time_period] == "1"
      @time_to_expire = 30
    else
      @time_to_expire = 90
    end
    if params[:search].present?
      params[:from_where] = "job_ticket"
      if params[:search_contracts].present?
        refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
        refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")
      end
      request.format = "xls"
      params[:per_page] = 100
      params[:sort_by] = true
      params[:query] = refined_search
      after_contract_products = []
      before_contract_products = Warranty.search(params)
      if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present?
        after_contract_products = Warranty.search(params)
        @warranties = (before_contract_products.results + after_contract_products.results).uniq{ |r| r.id }
      else
        @warranties = before_contract_products.results
      end

      not_need_index = []

      @warranties.each do |warranty|
        need_index_boolean = (( warranty.product.updated_at.to_datetime == Product.find(warranty.product.id).updated_at.to_datetime ) and (warranty.updated_at.to_datetime == Warranty.find(warranty.id).updated_at.to_datetime))
        not_need_index << {id: warranty.id, not_need_index: need_index_boolean} unless need_index_boolean
      end

      if @warranties.present?
        t_ids = []
        not_need_index.uniq{|n| n[:id]}.each do |n_index|
          t_ids << n_index[:id]
          # if !n_index[:not_need_index]
          #   # Ticket.find(n_index[:id]).update_index
          # end
        end

        Warranty.index.import Warranty.where(id: t_ids) if t_ids.present?

      end

    end

    respond_to do |format|
      if params[:search].present?
        sleep 3
        after_contract_products = []
        params[:report] = nil
        before_contract_products = Warranty.search(params)
        @warranties = if params[:ticket_contract_contract_start_at].present? and params[:ticket_contract_contract_end_at].present?
          params[:report] = true
          after_contract_products = Warranty.search(params)
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

  def contract_expire
    Ticket
    Invoice
    authorize! :contract_expire, TicketContract
    if params[:time_period] == "1"
      @time_to_expire = 30
    else
      @time_to_expire = 90
    end
    if params[:date_from].present?
      @contract_expire_list = TicketContract.all.select{|w| w.contract_end_at.to_date < params[:date_from].to_date.beginning_of_day}
      @contract_expireds = @contract_expire_list.sort_by{|e| e[:contract_end_at]}.reverse
    end
    if params[:search].present?
      if params[:search_contracts]
        refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
        refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")
      end
      request.format = "xls"
    end
    params[:from_where] = "expire_report"
    params[:per_page] = 100
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

  def hold_ticket_report
    Ticket
    User
    Product
    @tickets = Ticket.where("last_hold_action_id IS NOT NULL AND status_hold")

    render "reports/hold_ticket_report"
  end

  def returned_manufacture
    Ticket
    User
    Product
    TaskAction
    # @user_ticket_actions = UserTicketAction.joins(request_spare_part: :ticket_spare_part).where(action_id: 37, spt_act_request_spare_part: {spt_ticket_spare_part: {returned_part_accepted: false, close_approved: false}}).order("action_at desc")
    @user_ticket_actions = UserTicketAction.joins(request_spare_part: :ticket_spare_part).where(action_id: 37, "spt_ticket_spare_part.returned_part_accepted" => false, "spt_ticket_spare_part.close_approved" => false).page(params[:page]).per(100)
    # 37 action is Receive Spare part from Manufacture

    if params[:excel_output].present?
      render xlsx: "returned_manufacture"
    else
      render "returned_manufacture"
    end
  end

  def manufacture_colected
    Ticket
    User
    Product
    TaskAction
    TicketSparePart
    @ticket_manufactures = UserTicketAction.where(action_id: '31').order("action_at desc")

    render "reports/manufacture_colected"
  end  
  def cus_not_colected
    Ticket
    User
    Product
    TaskAction
    TicketSparePart
    Invoice
    # @tickets = Ticket.search(query: "ticket_type_name:'In house' AND job_finished:true AND NOT user_ticket_actions.action_id:58")
    # @tickets_58 = Ticket.search(query: "user_ticket_actions.action_id:58 AND user_ticket_actions.feedback_reopen:true")

    # @combined_tickets = Ticket.search(query: "ticket_type_code:'IH' AND job_finished:true").select{|t| t.user_ticket_actions.none?{|u| u.action_id == 58 and !u.feedback_reopen } }

    @combined_tickets = Ticket.where(ticket_type_id: '1', status_id:'6')
    @combined_tickets = @combined_tickets.sort{|p, n| [p.job_finished_at, p.qc_passed_at, p.final_invoice.try(:created_at)].compact.max <=> [n.job_finished_at, n.qc_passed_at, n.final_invoice.try(:created_at)].compact.max }
    # @combined_tickets = Ticket.includes(:final_invoice).select("GREATEST(spt_ticket.job_finished_at, spt_ticket.qc_passed_at, spt_ticket_invoice.created_at) AS net_date").where(ticket_type_id: '1', status_id:'6').order("net_date desc").references(:spt_ticket_invoice)


    
    # @combined_tickets = (@tickets.to_a + @tickets_58.to_a)
    # @ticket_manufactures = UserTicketAction.where.not(action_id: '58').order("action_at desc").to_a.uniq{|t| t.ticket_id }

    # Ticket.search(query: "NOT user_ticket_actions.action_id:58")
    # @ticket_manufactures = UserTicketAction.where(action_id: '58').order("action_at desc").to_a.uniq{|t| t.ticket_id }

    render "reports/cus_not_colected"
  end


  def order_updated
    TaskAction
    TicketSparePart
    @ticket_manufactures = TicketSparePartManufacture.where(order_pending: true)
    # @ticket_manufactures = UserTicketAction.where.not(action_id: '58').order("action_at desc").to_a.uniq{|t| t.ticket_id }

    # Ticket.search(query: "NOT user_ticket_actions.action_id:58")
    # @ticket_manufactures = UserTicketAction.where(action_id: '58').order("action_at desc").to_a.uniq{|t| t.ticket_id }

    render "reports/order_updated"
  end
  
  def delivered_items
    TicketSparePart
    @delivered_items = TicketDeliverUnit.where(delivered_to_sup: true, collected: false)
    render "reports/delivered_items"
  end
  def parts_pending
    TicketSparePart
    @pending_parts = TicketSparePartStore.where(store_requested: true, issued: false).order("store_requested_at desc")
    render "reports/parts_pending"
  end

  # and (request_approval_required= false or  request_approved = true)

  def parts_available
    TicketSparePart
    @available_parts = TicketSparePartStore.joins(:ticket_spare_part).where("spt_ticket_spare_part.received_eng_by is NULL AND spt_ticket_spare_part.available_mail_sent_at is NOT NULL").order("issued_at desc")#where("recived_eng_at IS NULL AND issued")
    render "reports/parts_available"
  end  

  def parts_order_history
    TicketSparePart
    @support_ticket_no = params[:serial_no]
    # @part_histories = TicketSparePart.where("created_at >= :start_date AND created_at <= :end_date", {start_date: (Date.today - 1.year), end_date: (Date.today + 1.day)})
    @part_histories = TicketSparePart.search(query: "ticket.product_info.serial_no:#{@support_ticket_no}", per_page: 100, page: params[:page])
    render "reports/parts_order_history"
  end
  def case_list
    TaskAction
    @ticket_no = params[:ticket_no]
    @case_lists = HpCase.all
    render "reports/case_list"
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

    if params[:search].present?
      params[:from_where] = "excel_output"

      search_ticket = params[:search_ticket]
      if params[:organization_children].present? and search_ticket["customer.organization_id"].present?
        organization_id = search_ticket["customer.organization_id"]
        organization = Organization.find(organization_id)
        anchestor_ids = organization.anchestors.map{|o| o[:member].id }
        search_ticket["customer.organization_id"] = "(#{anchestor_ids.join(' OR ')})" if anchestor_ids.any?
      end

      search_ticket['status_id'] = "(#{params[:status_ids].map { |e| e if e.present? }.compact.join(' OR ')})" if params[:status_ids].present?

      refined_search_ticket = search_ticket.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

      params[:range_from] ||= ( Date.today - 3.months ).strftime("%Y-%m-%d")
      params[:range_to] ||= Date.today.strftime("%Y-%m-%d")
    end
    params[:per_page] = 5000
    params[:query] = refined_search_ticket
    @ticket = Ticket.search(params)

    if params[:search].present?
      render xlsx: "excel_output"
    else
      respond_to do |format|
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
    currency_type = po.currency_type


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
      currencyType: currency_type,
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

  def quotation_report
    # render_xls = (params[:render_xls].present? and params[:render_xls].to_bool)
    rendon_no = params[:random_no].to_i
    if params[:search].present?
      Invoice
      quotation_params = params[:search_quotation]

      params[:created_at_to] = (params[:created_at_to].present? ? params[:created_at_to] : Date.today.strftime("%Y-%m-%d"))
      params[:created_at_from] = ( params[:created_at_to].to_date - 3.months ).strftime("%Y-%m-%d")

      refined_search_quotation = quotation_params.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

      params[:per_page] = 500
      params[:query] = refined_search_quotation
      @quotations = CustomerQuotation.search(params)
      render_xls = true
      # render_xls ||=  (@quotations.total_pages < 2 )
      # @random_no = rand(100)
      # Rails.cache.fetch( [ @random_no, :search_quotation_params ] ){ quotation_params }

      # elsif params[:export]
      #   quotation_params = Rails.cache.fetch( [ params[:randon_no].to_i, :search_quotation_params ] )
      #   refined_search_quotation = quotation_params.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      #   params[:per_page] = 500
      #   params[:query] = refined_search_quotation
      #   @quotations = CustomerQuotation.search(params)
      #   render_xls = true

      # elsif params[:reset]
      #   Rails.cache.delete( [ params[:randon_no].to_i, :search_quotation_params ] )
      #   render_xls = false

    else
      render_xls = false

    end

    if render_xls
      render xlsx: "quotation_report"

    else
      respond_to do |format|
        format.html
      end
    end
  end

  def customers
    # customers = Customer.select(:name).distinct.map(&:name)
    query = ["accounts_dealer_types.dealer_code:CUS"]
    query << "name:#{params[:q]}" if params[:q].present?
    params[:query] = query.map { |v| v if v.present? }.compact.join(" AND ")
    customers = Organization.search(params)
    # customers = Organization.search("name like ?", "%#{params[:q]}%")
    render json: {results: customers.map { |o| { id: o.id, text: o.name } }}
  end

  def manufacture_part_order_report
    Ticket
    TicketSparePart
    rendon_no = params[:random_no].to_i
    if params[:search].present?
      Invoice
      manufacture_part_params = params[:search_manufacture_part]
      manufacture_part_params['request_from'] = "M"

      if params['collected_date'].present?
        manufacture_part_params['ticket.user_ticket_actions.action_id'] = 36
        manufacture_part_params['ticket.user_ticket_actions.action_at'] = params['collected_date']
      end

      if params['return_part_accepted_date'].present? or params['return_part_accepted_by'].present?
        manufacture_part_params['ticket.user_ticket_actions.action_id'] = 43
        manufacture_part_params['ticket.user_ticket_actions.action_at'] = params['return_part_accepted_date'] if params['return_part_accepted_date'].present?
        manufacture_part_params['ticket.user_ticket_actions.action_by_name'] = params['return_part_accepted_by'] if params['return_part_accepted_by'].present?
      end

      if params['event_closed_by'].present?
        manufacture_part_params['ticket.user_ticket_actions.action_id'] = 44
        manufacture_part_params['ticket.user_ticket_actions.action_by'] = params['event_closed_by']
      end

      params[:created_at_to] = (params[:created_at_to].present? ? params[:created_at_to] : Date.today.strftime("%Y-%m-%d"))

      params[:created_at_from] = ( params[:created_at_to].to_date - 3.months ).strftime("%Y-%m-%d")

      refined_search_manufacture_part = manufacture_part_params.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

      params[:per_page] = 500
      params[:query] = refined_search_manufacture_part
      @part_orders = TicketSparePart.search(params)
      render_xls = true

    else
      render_xls = false

    end

    if render_xls
      render xlsx: "manufacture_part_order_report"

    else
      respond_to do |format|
        format.html
      end
    end
  end
end
