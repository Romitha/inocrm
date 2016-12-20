class ReportsController < ApplicationController
  # layout "report_pdf"

  def quotation
    # https://github.com/mileszs/wicked_pdf

    Invoice
    ContactNumber
    Tax

    quotation = CustomerQuotation.find params[:quotation_id]

    ticket = quotation.ticket

    product = ticket.products.first

    quotation_no = quotation.customer_quotation_no.to_s.rjust(6, INOCRM_CONFIG['quotation_no_format'])

    product_brand = product.product_brand.name

    model_no = product.model_no

    serial_no = product.serial_no

    product_no = product.product_no

    company_name = ticket.customer.full_name

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

    row_count = 0
    total_amount = 0
    total_advance_amount = 0
    currency = quotation.currency.try(:code)
    payment_term = quotation.payment_term.try(:name)
    warranty = quotation.warranty
    created_by = User.cached_find_by_id(quotation.created_by).try(:full_name)

    repeat_data = []

    quotation.customer_quotation_estimations.each do |ticket_quotation_estimation|
      ticket_estimation = ticket_quotation_estimation.ticket_estimation

      total_advance_amount += ticket_estimation.approval_required ? ticket_estimation.approved_adv_pmnt_amount.to_f : ticket_estimation.advance_payment_amount.to_f

      ticket_estimation.ticket_estimation_externals.each do |estimation_external|
        unit_price = ticket_estimation.approval_required ? estimation_external.approved_estimated_price.to_f : estimation_external.estimated_price.to_f


        repeat_data_hash = {}

        repeat_data_hash[:item_index] = row_count + 1
        # repeat_data_hash[:item_code] = index
        repeat_data_hash[:description] = "#{estimation_external.description}" + "#{' (Warr: ' + estimation_external.warranty_period.to_s + ' M)' if estimation_external.warranty_period.present? }"
        repeat_data_hash[:quantity] = 1
        repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
        repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)

        total_amount += unit_price

        repeat_data_hash[:currency] = ticket_estimation.currency.code

        repeat_data << repeat_data_hash

        estimation_external.ticket_estimation_external_taxes.each do |ticket_estimation_external_tax|
          repeat_data_hash = {}

          unit_price = ticket_estimation.approval_required ? ticket_estimation_external_tax.approved_tax_amount.to_f : ticket_estimation_external_tax.estimated_tax_amount.to_f

          repeat_data_hash[:item_index] = row_count + 1
          # repeat_data_hash[:item_code] = index
          repeat_data_hash[:description] = "#{ticket_estimation_external_tax.tax.tax} (#{ticket_estimation_external_tax.tax_rate})"
          # repeat_data_hash[:quantity] = 1
          # repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
          repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)

          total_amount += unit_price

          repeat_data_hash[:currency] = ticket_estimation.currency.code

          repeat_data << repeat_data_hash

        end

      end

      ticket_estimation.ticket_estimation_parts.each do |estimation_part|
        total_price = ticket_estimation.approval_required ? estimation_part.approved_estimated_price.to_f : estimation_part.estimated_price.to_f

        quantity = ( ( estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock ).try(:approved_quantity) or ( estimation_part.ticket_spare_part.ticket_spare_part_manufacture or estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock ).try(:requested_quantity) )

        unit_price = (quantity and quantity.to_f != 0) ? total_price/quantity.to_f : 0

        repeat_data_hash = {}

        repeat_data_hash[:item_index] = row_count + 1
        # repeat_data_hash[:item_code] = index
        repeat_data_hash[:description] = "Part No: #{estimation_part.ticket_spare_part.spare_part_no} #{estimation_part.ticket_spare_part.spare_part_description}" + "#{' (Warr: ' + estimation_part.warranty_period.to_s + ' M)' if estimation_part.warranty_period.present? }"

        repeat_data_hash[:quantity] = quantity
        repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
        repeat_data_hash[:totalprice] = view_context.standard_currency_format(total_price)

        total_amount += total_price

        repeat_data_hash[:currency] = ticket_estimation.currency.code

        repeat_data << repeat_data_hash

        estimation_part.ticket_estimation_part_taxes.each do |ticket_estimation_part_tax|

          unit_price = ticket_estimation.approval_required ? ticket_estimation_part_tax.approved_tax_amount.to_f : ticket_estimation_part_tax.estimated_tax_amount.to_f

          repeat_data_hash = {}

          repeat_data_hash[:item_index] = row_count + 1
          # repeat_data_hash[:item_code] = index
          repeat_data_hash[:description] = "#{ticket_estimation_part_tax.tax.tax} (#{ticket_estimation_part_tax.tax_rate})"

          # repeat_data_hash[:quantity] = quantity
          # repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)
          repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)

          total_amount += unit_price

          repeat_data_hash[:currency] = ticket_estimation.currency.code

          repeat_data << repeat_data_hash

        end

      end

      ticket_estimation.ticket_estimation_additionals.each do |ticket_estimation_additional|
        repeat_data_hash = {}

        unit_price = ticket_estimation.approval_required ? ticket_estimation_additional.approved_estimated_price.to_f : ticket_estimation_additional.estimated_price.to_f

        repeat_data_hash[:item_index] = row_count + 1

        repeat_data_hash[:description] = ticket_estimation_additional.additional_charge.additional_charge
        repeat_data_hash[:quantity] = 1
        repeat_data_hash[:unit_price] = view_context.standard_currency_format(unit_price)

        repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)
        total_amount += unit_price

        repeat_data_hash[:currency] = ticket_estimation.currency.code

        repeat_data << repeat_data_hash

        ticket_estimation_additional.ticket_estimation_additional_taxes.each do |ticket_estimation_additional_tax|
          repeat_data_hash = {}

          unit_price = ticket_estimation.approval_required ? ticket_estimation_additional_tax.approved_tax_amount.to_f : ticket_estimation_additional_tax.estimated_tax_amount.to_f

          repeat_data_hash[:item_index] = row_count + 1

          repeat_data_hash[:description] = "#{ticket_estimation_additional_tax.tax.tax} (#{ticket_estimation_additional_tax.tax_rate})"

          repeat_data_hash[:totalprice] = view_context.standard_currency_format(unit_price)
          total_amount += unit_price

          repeat_data_hash[:currency] = ticket_estimation.currency.code

          repeat_data << repeat_data_hash
        end

      end

    end

    @print_object = {
      duplicate_d: "#{'D' if ticket.ticket_complete_print_count > 0}",
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
      total_amount: total_amount,
      currency: currency,
      payment_term: payment_term,
      warranty: warranty,
      note: quotation_note,
      created_by: created_by,
      row_count: row_count,
      total_amount: total_amount,
      total_advance_amount: total_advance_amount,

    }

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
          layout: "report_pdf"
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
    @ticket = Ticket.all
    respond_to do |format|
      format.html
      format.xls
    end
  end
end
