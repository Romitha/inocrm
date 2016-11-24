module ApplicationHelper
  #                               PRINT_SPPT_FSR, print_fsr_tag_value(fsr)method, fsr template from print template table
  def request_printer_application print_request_type, tag_values, print_template
    # 3$|#REQUEST_TYPE=PRINT_TICKET$|#DATETIME=2015/06/21 12:10 PM$|#DUPLICATE=$|#TICKET_REF=T0005$|#.....$|#TEMPLATE=< xml data >
    delim = "$|#"
    request_type = "REQUEST_TYPE="
    template = "TEMPLATE="
    if tag_values.is_a? Array
      rq_str = "#{delim.length}#{delim}#{request_type}#{print_request_type}#{delim}#{tag_values.join(delim)}#{delim}#{template}#{print_template}"

    else
      raise ArgumentError, 'tag_values type is not array'
    end
  end

  def print_ticket_tag_value ticket #REQUEST_TYPE=PRINT_SPPT_TICKET
    [
      "DUPLICATE=#{ticket.ticket_print_count > 0 ? 'D' : ''}",
      "DATETIME=#{ticket.created_at.strftime(INOCRM_CONFIG['long_date_format']+' '+INOCRM_CONFIG['time_format'])}",
      "TICKET_REF=#{ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}",
      "COMPANY_NAME=#{ticket.customer.mst_title.title} #{ticket.customer.name}",
      "CONTACT_PERSON=#{ticket.contact_person1.mst_title.title} #{ticket.contact_person1.name}",
      "ADDRESS=#{ticket.customer.address1} #{ticket.customer.address2} #{ticket.customer.address3} #{ticket.customer.address4}",
      "TELPHONE=#{ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Telephone"}.first.try(:value)}",
      "MOBILE=#{ticket.customer.contact_type_values.select{|c| c.contact_type.mobile}.first.try(:value)}",
      "FAX=#{ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Fax"}.first.try(:value)}",
      "EMAIL=#{ticket.customer.contact_type_values.select{|c| c.contact_type.email}.first.try(:value)}",
      "PRODUCT_BRAND=#{ticket.products.first.product_brand.name}",
      "PRODUCT_CATEGORY=#{ticket.products.first.product_category.name}",
      "MODEL_NO=#{ticket.products.first.model_no}",
      "SERIAL_NO=#{ticket.products.first.serial_no}",
      "PRODUCT_NO=#{ticket.products.first.product_no}",
      "PROBLEM_DESC1=#{ticket.problem_description.to_s[0..100]}",
      "PROBLEM_DESC2=#{ticket.problem_description.to_s[101..200]}",
      "WARRANTY=#{'X' if ticket.products.first.warranties.any?{|w| (w.start_at.to_date..w.end_at.to_date).include?(ticket.created_at.to_date)}}",
      "CHARGEABLE=#{'X' if ticket.cus_chargeable}",
      "NEED_POP=#{'X' if ticket.products.first.product_pop_status.code != 'NAP'}",
      "EXTRA_REMARK1=#{ticket.ticket_extra_remarks.first.try(:extra_remark).try(:extra_remark)}",
      "EXTRA_REMARK2=#{ticket.ticket_extra_remarks.second.try(:extra_remark).try(:extra_remark)}",
      "EXTRA_REMARK3=#{ticket.ticket_extra_remarks.third.try(:extra_remark).try(:extra_remark)}",
      "EXTRA_REMARK4=#{ticket.ticket_extra_remarks.fourth.try(:extra_remark).try(:extra_remark)}",
      "EXTRA_REMARK5=#{ticket.ticket_extra_remarks.fifth.try(:extra_remark).try(:extra_remark)}",
      "EXTRA_REMARK6=",
      "REMARK=#{ticket.remarks.split('<span class=\'pop_note_e_time\'>').first if ticket.remarks.present?}",
      "ACCESSORY1=#{ticket.accessories.first.try(:accessory)}",
      "ACCESSORY2=#{ticket.accessories.second.try(:accessory)}",
      "ACCESSORY3=#{ticket.accessories.third.try(:accessory)}",
      "ACCESSORY4=#{ticket.accessories.fourth.try(:accessory)}",
      "ACCESSORY5=#{ticket.accessories.fifth.try(:accessory)}",
      "ACCESSORY6=",
      "ACCESSORY_OTHER=#{ticket.other_accessories}"
    ]

  end

  def print_fsr_tag_value fsr #REQUEST_TYPE=PRINT_SPPT_FSR
    [
      "DUPLICATE=#{fsr.print_count > 0 ? 'D' : ''}",
      "FSR_NO=#{fsr.ticket_fsr_no.to_s.rjust(6, INOCRM_CONFIG['fsr_no_format'])}",
      "COMPANY_NAME=#{fsr.ticket.customer.mst_title.title} #{fsr.ticket.customer.name}",
      "ADDRESS=#{fsr.ticket.customer.address1} #{fsr.ticket.customer.address2} #{fsr.ticket.customer.address3} #{fsr.ticket.customer.address4}",
      "TELPHONE=#{fsr.ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Telephone"}.first.try(:value)}",
      "MOBILE=#{fsr.ticket.customer.contact_type_values.select{|c| c.contact_type.mobile}.first.try(:value)}",
      "TICKET_REF=#{fsr.ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}",
      "ENGINEER=#{fsr.ticket.owner_engineer and fsr.ticket.owner_engineer.user.full_name}",
      "SERIAL_NO=#{fsr.ticket.products.first.serial_no}",
      "PRODUCT_DETAILS=#{[fsr.ticket.products.first.product_brand.name, fsr.ticket.products.first.product_category.name, fsr.ticket.products.first.model_no, fsr.ticket.products.first.product_no].join(' / ')}",
      "PRODUCT_BRAND=#{fsr.ticket.products.first.product_brand.name}",
      "PRODUCT_CATEGORY=#{fsr.ticket.products.first.product_category.name}",
      "MODEL_NO=#{fsr.ticket.products.first.model_no}",
      "PRODUCT_NO=#{fsr.ticket.products.first.product_no}",
      "PROBLEM_DESC1=#{fsr.ticket.problem_description.to_s[0..100]}",
      "PROBLEM_DESC2=#{fsr.ticket.problem_description.to_s[101..200]}",
      "TICKET_CREATED_DATE=#{fsr.ticket.created_at.strftime(INOCRM_CONFIG['long_date_format'])}",
      "TICKET_CREATED_TIME=#{fsr.ticket.created_at.strftime(INOCRM_CONFIG['time_format'])}"
    ]    
  end

  def print_receipt_tag_value receipt #REQUEST_TYPE=PRINT_SPPT_RECEIPT
    [
      "DUPLICATE=#{receipt.receipt_print_count > 0 ? 'D' : ''}",
      "RECEIPT_NO=#{receipt.id.to_s.rjust(6, INOCRM_CONFIG['receipt_no_format'])}",
      "COMPANY_NAME=#{receipt.ticket.customer.full_name}",
      "TICKET_REF=#{receipt.ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}",
      "INVOICE_NO=#{ receipt.ticket_invoice and receipt.ticket_invoice.invoice_no.to_s.rjust(6, INOCRM_CONFIG['invoice_no_format'])}",
      "AMOUNT=#{standard_currency_format(receipt.amount)}",
      "DESCRIPTION=#{receipt.receipt_description.truncate(18)}",
      "PAYMENT_TYPE=#{TicketPaymentReceivedType::TYPES.key(receipt.payment_type)}",
      "PAYMENT_NOTE=#{receipt.payment_note.to_s.try(:truncate, 18)}",
      "TYPE=#{receipt.ticket_payment_received_type.name}",
      "NOTE=#{receipt.note.to_s.truncate(18)}",
      "CREATED_DATE=#{receipt.created_at.strftime(INOCRM_CONFIG['long_date_format'])}",
      "CREATED_TIME=#{receipt.created_at.strftime(INOCRM_CONFIG['time_format'])}",
      "CREATED_BY=#{User.cached_find_by_id(receipt.received_by).full_name}"
    ]
  end

  def print_ticket_sticker_tag_value ticket  #REQUEST_TYPE=PRINT_SPPT_TICKET_STICKER

    ticket_ref = ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])
    image_barcode = ""

    [
      "TICKET_REF=#{ticket_ref}",
      "IMAGE_BARCODE=#{image_barcode}",
    ]

  end

  def print_ticket_delivery_note_tag_value ticket  #REQUEST_TYPE=PRINT_SPPT_TICKET_COMPLETE
    TaskAction
    Invoice
    ContactNumber
    customer_feedback = ticket.user_ticket_actions.select{ |u| u.customer_feedback.present? and not u.customer_feedback.re_opened }.last.try(:customer_feedback) # may or may not
    customer = ticket.customer
    product = ticket.products.first
    accessories = ticket.accessories
    final_invoice = ticket.ticket_invoices.order(created_at: :desc).find_by_canceled false

    ticket_ref = ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])
    ticket_datetime = ticket.created_at.strftime(INOCRM_CONFIG['long_date_format']+' '+INOCRM_CONFIG['time_format'])
    company_name = customer.full_name
    address1 = customer.address1
    address2 = customer.address2
    address3 = customer.address3
    address4 = customer.address4
    mobile = customer.contact_type_values.select{|c| c.contact_type.mobile }.first.try(:value)
    serial_no = product.serial_no
    model_no = product.model_no
    product_brand = product.product_brand.name
    product_category = product.product_category.name
    special_note = ticket.note
    accessory1 = accessories.first.try(:accessory)
    accessory2 = accessories.second.try(:accessory)
    accessory3 = accessories.third.try(:accessory)
    accessory4 = accessories.fourth.try(:accessory)
    accessory5 = accessories.fifth.try(:accessory)
    accessory_other = ticket.other_accessories
    problem_des1 = ticket.problem_description.to_s[0..100]
    problem_des2 = ticket.problem_description.to_s[101..200]
    resolution_summary1 = ticket.resolution_summary.to_s[0..100]
    resolution_summary2 = ticket.resolution_summary.to_s[101..200]
    invoice_no = (final_invoice and final_invoice.invoice_no.to_s.rjust(6, INOCRM_CONFIG['invoice_no_format']))

    if customer_feedback
      deliver_datetime = customer_feedback.user_ticket_action.action_at.try(:strftime, INOCRM_CONFIG['long_date_format']+' '+INOCRM_CONFIG['time_format'])
      deliver_method = customer_feedback.dispatch_method.try(:name)
      deliver_note = customer_feedback.feedback_description
      delivered_by = User.cached_find_by_id(customer_feedback.user_ticket_action.action_by).full_name 
    end

    left_count = right_count = 0

    left_data = {
      "Ticket #:" => "#{ticket_ref} - #{ticket_datetime}",
      "Delivered To :" => [company_name, address1, address2, address3, address4],
      "Mobile No :" => mobile,
      "Serial No :" => serial_no,
      "Product Brand :" => product_brand,
      "Model No :" => model_no,
      "Product Category :" => product_category,
      "Special Notes :" => [special_note.to_s[0..100], special_note.to_s[101..200],special_note.to_s[101..200]],
      "Accessories :" => [accessory1, accessory2, accessory3, accessory4, accessory5],
      "Other Accessories :" => accessory_other,
    }.map do |k, v|
      if v.is_a?(Array)
        left_count += v.count
        "LEFT_LINE_TITLE=#{k}$|#LEFT_LINE_DATA=#{v.first}$|#" + v.from(1).map { |e| "LEFT_LINE_TITLE=$|#LEFT_LINE_DATA=#{e}$|#" }.join
      else
        left_count += 1
        "LEFT_LINE_TITLE=#{k}$|#LEFT_LINE_DATA=#{v}$|#"
      end
    end

    right_data = {
      "Reported failure :" => [problem_des1, problem_des2],
      "Resolution :" => [resolution_summary1, resolution_summary2],
      "Invoice #:" => invoice_no,
      "Delivery Date :" => deliver_datetime,
      "Delivery Method :" => deliver_method,
      "Delivery Note :" => deliver_note,
      "Released By :" => delivered_by,
      "Signature :" => "",
    }.map do |k, v|
      if v.is_a?(Array)
        right_count += v.count
        "RIGHT_LINE_TITLE=#{k}$|#RIGHT_LINE_DATA=#{v.first}$|#" + v.from(1).map { |e| "RIGHT_LINE_TITLE=$|#RIGHT_LINE_DATA=#{e}$|#" }.join
      else
        right_count += 1
        "RIGHT_LINE_TITLE=#{k}$|#RIGHT_LINE_DATA=#{v}$|#"
      end

    end

    if left_count > right_count
      right_data.fill("RIGHT_LINE_TITLE=$|#RIGHT_LINE_DATA=$|#", right_data.count, (left_count - right_count))
    elsif left_count < right_count
      left_data.fill("LEFT_LINE_TITLE=$|#LEFT_LINE_DATA=$|#", left_data.count, (right_count - left_count))
    end

    repeat_data = (left_data + right_data).join

    [
      "DUPLICATE_D=#{ticket.ticket_complete_print_count > 0 ? 'D' : ''}",
      repeat_data,
      "DELIVERY_DATETIME=#{deliver_datetime}",
    ]

  end

  def print_customer_quotation_tag_value quotation #REQUEST_TYPE=PRINT_SPPT_QUOTATION
    Invoice
    ContactNumber

    ticket = quotation.ticket
    ticket_date = ticket.created_at.strftime(INOCRM_CONFIG['long_date_format'])
    ticket_time = ticket.created_at.strftime(INOCRM_CONFIG['time_format'])
    ticket_ref = ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])
    company_name = ticket.customer.mst_title.title+" "+ticket.customer.name
    contact_person = "#{ticket.contact_person1.mst_title.title} #{ticket.contact_person1.name}"
    address1 = ticket.customer.address1
    address2 = ticket.customer.address2
    address3 = ticket.customer.address3
    address4 = ticket.customer.address4
    telephone = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Telephone"}.first.try(:value)
    mobile = ticket.customer.contact_type_values.select{|c| c.contact_type.mobile}.first.try(:value)
    fax = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Fax"}.first.try(:value)
    email = ticket.customer.contact_type_values.select{|c| c.contact_type.email}.first.try(:value)
    product_brand = ticket.products.first.product_brand.name
    product_category = ticket.products.first.product_category.name
    model_no = ticket.products.first.model_no
    serial_no = ticket.products.first.serial_no
    product_no = ticket.products.first.product_no
    problem_des1 = ticket.problem_description.to_s[0..100]
    problem_des2 = ticket.problem_description.to_s[101..200]
    extra_remark1 = ticket.ticket_extra_remarks.first.try(:extra_remark).try(:extra_remark)
    extra_remark2 = ticket.ticket_extra_remarks.second.try(:extra_remark).try(:extra_remark)
    extra_remark3 = ticket.ticket_extra_remarks.third.try(:extra_remark).try(:extra_remark)
    extra_remark4 = ticket.ticket_extra_remarks.fourth.try(:extra_remark).try(:extra_remark)
    extra_remark5 = ticket.ticket_extra_remarks.fifth.try(:extra_remark).try(:extra_remark)
    extra_remark6 = ticket.ticket_extra_remarks[5].try(:extra_remark).try(:extra_remark)
    remark = ticket.remarks.split('<span class=\'pop_note_e_time\'>').first if ticket.remarks.present?
    accessory1 = ticket.accessories.first.try(:accessory)
    accessory2 = ticket.accessories.second.try(:accessory)
    accessory3 = ticket.accessories.third.try(:accessory)
    accessory4 = ticket.accessories.fourth.try(:accessory)
    accessory5 = ticket.accessories.fifth.try(:accessory)
    accessory_other = ticket.other_accessories
    resolution_summary1 = ticket.resolution_summary.to_s[0..100]
    resolution_summary2 = ticket.resolution_summary.to_s[101..200]
    quotation_no = quotation.customer_quotation_no.to_s.rjust(6, INOCRM_CONFIG['quotation_no_format'])
    special_note = ticket.note
    quotation_note = quotation.note
    created_by = User.cached_find_by_id(quotation.created_by).try(:full_name)
    payment_term = quotation.payment_term.try(:name)
    validity_period = quotation.validity_period
    delivery_period = quotation.delivery_period
    warranty = quotation.warranty

    total_amount = 0
    net_total_amount = 0
    total_advance_amount = 0
    totalprice = 0
    unit_price = 0
    currency = quotation.currency.try(:code)

    item_index = 0
    repeat_data = ""
    quotation.customer_quotation_estimations.each do |ticket_quotation_estimation|
      ticket_estimation = ticket_quotation_estimation.ticket_estimation
      quantity = 1
      currency_1 = ticket_estimation.currency.code
      advance_amount = ticket_estimation.approval_required ? ticket_estimation.approved_adv_pmnt_amount.to_f : ticket_estimation.advance_payment_amount.to_f
      total_advance_amount += advance_amount

      if ticket_estimation.ticket_estimation_externals.present?
        estimation_external = ticket_estimation.ticket_estimation_externals.first
        item_index += 1
        description = "#{estimation_external.description}" + "#{' (Warr: ' + estimation_external.warranty_period.to_s + ' M)' if estimation_external.warranty_period.present? }"

        unit_price = ticket_estimation.approval_required ? estimation_external.approved_estimated_price.to_f : estimation_external.estimated_price.to_f

        quantity = 1
        totalprice = unit_price
        total_amount += totalprice

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => totalprice, "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        estimation_external.ticket_estimation_external_taxes.each do |ticket_estimation_external_tax|
          item_index += 1
          description = "#{ticket_estimation_external_tax.tax.tax} (#{ticket_estimation_external_tax.tax_rate})"
          unit_price = ticket_estimation.approval_required ? ticket_estimation_external_tax.approved_tax_amount.to_f : ticket_estimation_external_tax.estimated_tax_amount.to_f

          totalprice = unit_price
          total_amount += totalprice
          net_total_amount += totalprice

          repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
        end

      end

      if ticket_estimation.ticket_estimation_parts.present?
        estimation_part = ticket_estimation.ticket_estimation_parts.first
        item_index += 1
        description = "Part No: #{estimation_part.ticket_spare_part.spare_part_no} #{estimation_part.ticket_spare_part.spare_part_description}" + "#{' (Warr: ' + estimation_part.warranty_period.to_s + ' M)' if estimation_part.warranty_period.present? }"
        item_code = estimation_part.ticket_spare_part.ticket_spare_part_store.present? ? estimation_part.ticket_spare_part.ticket_spare_part_store.approved_inventory_product.try(:generated_item_code) : ""

        totalprice = ticket_estimation.approval_required ? estimation_part.approved_estimated_price.to_f : estimation_part.estimated_price.to_f

        quantity = ( ( estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock ).try(:approved_quantity) or 1 )

        unit_price = totalprice / quantity 
        total_amount += totalprice
        net_total_amount += totalprice

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => item_code, "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        estimation_part.ticket_estimation_part_taxes.each do |ticket_estimation_part_tax|
          item_index += 1
          description = "#{ticket_estimation_part_tax.tax.tax} (#{ticket_estimation_part_tax.tax_rate})"

          unit_price = ticket_estimation.approval_required ? ticket_estimation_part_tax.approved_tax_amount.to_f : ticket_estimation_part_tax.estimated_tax_amount.to_f
      
          totalprice = unit_price
          total_amount += totalprice

          repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
        end
      end

      ticket_estimation.ticket_estimation_additionals.each do |ticket_estimation_additional|
        item_index += 1
        description = ticket_estimation_additional.additional_charge.additional_charge
        unit_price = ticket_estimation.approval_required ? ticket_estimation_additional.approved_estimated_price.to_f : ticket_estimation_additional.estimated_price.to_f

        totalprice = unit_price
        total_amount += totalprice

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        ticket_estimation_additional.ticket_estimation_additional_taxes.each do |ticket_estimation_additional_tax|
          item_index += 1
          description = "#{ticket_estimation_additional_tax.tax.tax} (#{ticket_estimation_additional_tax.tax_rate})"
          unit_price = ticket_estimation.approval_required ? ticket_estimation_additional_tax.approved_tax_amount.to_f : ticket_estimation_additional_tax.estimated_tax_amount.to_f
        
          totalprice = unit_price
          total_amount += totalprice

          repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        end
      end
    end


    [
      "DUPLICATE_D=#{ticket.ticket_complete_print_count > 0 ? 'D' : ''}",
      "QUOTATION_NO=#{quotation_no}",
      "PRODUCT_BRAND=#{product_brand}",
      "MODEL_NO=#{model_no}",
      "SERIAL_NO=#{serial_no}",
      "PRODUCT_NO=#{product_no}",
      "COMPANY_NAME=#{company_name}",
      "ADDRESS1=#{address1}",
      "ADDRESS2=#{address2}",
      "ADDRESS3=#{address3}",
      "ADDRESS4=#{address4}",
      "TICKET_REF=#{ticket_ref}",
      "CREATED_DATE=#{ticket_date}",
      "CREATED_TIME=#{ticket_time}",
      "VALIDITY_PERIOD=#{validity_period}",
      "DELIVERY_PERIOD=#{delivery_period}",
      repeat_data,
      "TOTAL_AMOUNT=#{standard_currency_format total_amount}",
      "CURRENCY3=#{currency}",
      "MINIMUM_ADVANCE_PAYMENT=#{standard_currency_format total_advance_amount}",
      "CURRENCY4=#{currency}",
      "PAYMENT_TERM=#{payment_term}",
      "WARRANTY=#{warranty}",
      "NOTE=#{quotation_note}",
      "CREATED_BY=#{created_by}"
    ]

  end

  def print_bundle_tag_value bundle  #REQUEST_TYPE=PRINT_SPPT_BUNDLE_HP

    repeat_data = ""
    total_count = 0
    bundle.ticket_spare_parts.each_with_index do |spare_part, index|
      index_no = index+1
      total_count = index+1
      event_no = spare_part.ticket_spare_part_manufacture.event_no
      spare_part_no = spare_part.spare_part_no
      used_status = spare_part.spare_part_status_use.name
      
      repeat_data += {"INDEX_NO" => index_no, "EVENT_NO" => event_no, "SPARE_PART_NO" => spare_part_no, "USED_STATUS" => used_status}.map { |k, v| "#{k}=#{v}$|#" }.join
    end

    [
      "BUNDLE_NO=#{bundle.bundle_no}",
      "CREATED_DATE=#{bundle.created_at.strftime(INOCRM_CONFIG['long_date_format'])}",
      "CREATED_TIME=#{bundle.created_at.strftime(INOCRM_CONFIG['time_format'])}",
      repeat_data,
      "TOTAL_COUNT=#{total_count}",
      "NOTE1=#{bundle.note.to_s[0..100]}",
      "NOTE2=#{bundle.note.to_s[101..200]}",
      "NOTE3=#{bundle.note.to_s[201..300]}",
      "CREATED_BY=#{User.cached_find_by_id(bundle.created_by).full_name}"
    ]

  end


  def print_ticket_invoice_tag_value ticket_invoice  #REQUEST_TYPE=PRINT_SPPT_INVOICE
    Invoice
    ContactNumber
    invoice = ticket_invoice

    ticket = invoice.ticket
    ticket_date = ticket.created_at.strftime(INOCRM_CONFIG['long_date_format'])
    ticket_time = ticket.created_at.strftime(INOCRM_CONFIG['time_format'])
    ticket_ref = ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])
    company_name = ticket.customer.mst_title.title+" "+ticket.customer.name
    contact_person = "#{ticket.contact_person1.mst_title.title} #{ticket.contact_person1.name}"
    address1 = ticket.customer.address1
    address2 = ticket.customer.address2
    address3 = ticket.customer.address3
    address4 = ticket.customer.address4
    telephone = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Telephone"}.first.try(:value)
    mobile = ticket.customer.contact_type_values.select{|c| c.contact_type.mobile}.first.try(:value)
    fax = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Fax"}.first.try(:value)
    email = ticket.customer.contact_type_values.select{|c| c.contact_type.email}.first.try(:value)
    product_brand = ticket.products.first.product_brand.name
    product_category = ticket.products.first.product_category.name
    model_no = ticket.products.first.model_no
    serial_no = ticket.products.first.serial_no
    product_no = ticket.products.first.product_no
    problem_des1 = ticket.problem_description.to_s[0..100]
    problem_des2 = ticket.problem_description.to_s[101..200]
    extra_remark1 = ticket.ticket_extra_remarks.first.try(:extra_remark).try(:extra_remark)
    extra_remark2 = ticket.ticket_extra_remarks.second.try(:extra_remark).try(:extra_remark)
    extra_remark3 = ticket.ticket_extra_remarks.third.try(:extra_remark).try(:extra_remark)
    extra_remark4 = ticket.ticket_extra_remarks.fourth.try(:extra_remark).try(:extra_remark)
    extra_remark5 = ticket.ticket_extra_remarks.fifth.try(:extra_remark).try(:extra_remark)
    extra_remark6 = ticket.ticket_extra_remarks[5].try(:extra_remark).try(:extra_remark)
    remark = ticket.remarks.split('<span class=\'pop_note_e_time\'>').first if ticket.remarks.present?
    accessory1 = ticket.accessories.first.try(:accessory)
    accessory2 = ticket.accessories.second.try(:accessory)
    accessory3 = ticket.accessories.third.try(:accessory)
    accessory4 = ticket.accessories.fourth.try(:accessory)
    accessory5 = ticket.accessories.fifth.try(:accessory)
    accessory_other = ticket.other_accessories
    resolution_summary1 = ticket.resolution_summary.to_s[0..100]
    resolution_summary2 = ticket.resolution_summary.to_s[101..200]
    invoice_no = invoice.invoice_no.to_s.rjust(6, INOCRM_CONFIG['invoice_no_format'])
    payment_term = invoice.try(:payment_term).try(:name)
    special_note = ticket.note
    invoice_note = invoice.note
    created_by = invoice.created_by_ch_eng.full_name

    total_amount = 0
    net_total_amount = 0
    currency = invoice.currency.try(:code)
    total_advance_recieved = 0
    total_deduction = 0
    balance_tobe_paid = 0
    db_net_total_amount = 0

    item_index = 0
    repeat_data = ""
    invoice.ticket_invoice_estimations.each do |ticket_invoice_estimation|
      quantity = 1
      currency_1 = ticket_invoice_estimation.ticket_estimation.currency.code

      if ticket_invoice_estimation.ticket_estimation.ticket_estimation_externals.present?
        estimation_external = ticket_invoice_estimation.ticket_estimation.ticket_estimation_externals.first
        item_index += 1
        description = estimation_external.description

        unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? estimation_external.approved_estimated_price.to_f : estimation_external.estimated_price.to_f

        quantity = 1
        totalprice = unit_price
        total_amount += totalprice
        net_total_amount += totalprice

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => totalprice, "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        estimation_external.ticket_estimation_external_taxes.each do |ticket_estimation_external_tax|
          item_index += 1
          description = "#{ticket_estimation_external_tax.tax.tax} (#{ticket_estimation_external_tax.tax_rate})"
          unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? ticket_estimation_external_tax.approved_tax_amount.to_f : ticket_estimation_external_tax.estimated_tax_amount.to_f

          totalprice = unit_price
          total_amount += totalprice
          net_total_amount += totalprice

          repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
        end

      end

      if ticket_invoice_estimation.ticket_estimation.ticket_estimation_parts.present?
        estimation_part = ticket_invoice_estimation.ticket_estimation.ticket_estimation_parts.first
        item_index += 1
        description = "Part No: #{estimation_part.ticket_spare_part.spare_part_no} #{estimation_part.ticket_spare_part.spare_part_description}"
        item_code = estimation_part.ticket_spare_part.ticket_spare_part_store.present? ? estimation_part.ticket_spare_part.ticket_spare_part_store.approved_inventory_product.generated_item_code : ""

        totalprice = ticket_invoice_estimation.ticket_estimation.approval_required ? estimation_part.approved_estimated_price.to_f : estimation_part.estimated_price.to_f

        quantity = ( ( estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock).try(:approved_quantity ) or 1 )

        unit_price = totalprice / quantity
        total_amount += totalprice
        net_total_amount += totalprice

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => item_code, "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        estimation_part.ticket_estimation_part_taxes.each do |ticket_estimation_part_tax|
          item_index += 1
          description = "#{ticket_estimation_part_tax.tax.tax} (#{ticket_estimation_part_tax.tax_rate})"

          unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? ticket_estimation_part_tax.approved_tax_amount.to_f : ticket_estimation_part_tax.estimated_tax_amount.to_f
      
          totalprice = unit_price
          total_amount += totalprice
          net_total_amount += totalprice

          repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
        end
      end

      ticket_invoice_estimation.ticket_estimation.ticket_estimation_additionals.each do |ticket_estimation_additional|
        item_index += 1
        description = ticket_estimation_additional.additional_charge.additional_charge
        unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? ticket_estimation_additional.approved_estimated_price.to_f : ticket_estimation_additional.estimated_price.to_f

        totalprice = unit_price
        total_amount += totalprice
        net_total_amount += totalprice

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        ticket_estimation_additional.ticket_estimation_additional_taxes.each do |ticket_estimation_additional_tax|
          item_index += 1
          description = "#{ticket_estimation_additional_tax.tax.tax} (#{ticket_estimation_additional_tax.tax_rate})"
          unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? ticket_estimation_additional_tax.approved_tax_amount.to_f : ticket_estimation_additional_tax.estimated_tax_amount.to_f
        
          totalprice = unit_price
          total_amount += totalprice
          net_total_amount += totalprice

          repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        end
      end
    end

    invoice.ticket_invoice_terminates.each do |ticket_invoice_terminate|
      currency_1 = ticket_invoice_terminate.act_terminate_job_payment.currency.code
      item_index += 1
      description = ticket_invoice_terminate.act_terminate_job_payment.payment_item.name
      unit_price = ticket_invoice_terminate.act_terminate_job_payment.amount.to_f

      totalprice = unit_price
      total_amount += totalprice
      net_total_amount += totalprice

      repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
    end

    invoice.ticket_invoice_advance_payments.each do |ticket_invoice_advance_payment|
      currency_1 = ticket_invoice_advance_payment.ticket_payment_received.currency.code
      
      item_index += 1
      description = "Advanced Payment Recieved on : #{ticket_invoice_advance_payment.ticket_payment_received.received_at.strftime(INOCRM_CONFIG['long_date_format'])}"
      unit_price = -ticket_invoice_advance_payment.ticket_payment_received.amount.to_f
      totalprice = unit_price
      total_advance_recieved += totalprice
      net_total_amount += totalprice

      repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join


    end

    if invoice.deducted_amount.to_d > 0
      currency_1 = invoice.currency.code
      item_index += 1
      description = "Deduction"
      unit_price = -invoice.deducted_amount.to_f
      totalprice = unit_price
      total_deduction += totalprice
      net_total_amount += totalprice

      repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => totalprice, "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
    end

    @db_total_amount = invoice.total_amount
    db_net_total_amount = invoice.net_total_amount
    @db_total_advance_recieved = -invoice.total_advance_recieved
    @db_total_deduction = -invoice.total_deduction
    if (db_net_total_amount != net_total_amount) or (@db_total_advance_recieved != total_advance_recieved) or (@db_total_deduction != total_deduction)
      @total_error="Calculation Error In Totals: net_total_amount=#{net_total_amount} total_advance_recieved=#{total_advance_recieved} total_deduction=#{total_deduction}"
    end

    [
      "DUPLICATE_D=#{ticket.ticket_complete_print_count > 0 ? 'D' : ''}",
      "INVOICE_NO=#{invoice_no}",
      "PRODUCT_BRAND=#{product_brand}",
      "MODEL_NO=#{model_no}",
      "SERIAL_NO=#{serial_no}",
      "PRODUCT_NO=#{product_no}",
      "COMPANY_NAME=#{company_name}",
      "ADDRESS1=#{address1}",
      "ADDRESS2=#{address2}",
      "ADDRESS3=#{address3}",
      "ADDRESS4=#{address4}",
      "TICKET_REF=#{ticket_ref}",
      "CREATED_DATE=#{ticket_date}",
      "CREATED_TIME=#{ticket_time}",
      "PAYMENT_TERM=#{payment_term}",
      repeat_data,
      "TOTAL_AMOUNT=#{standard_currency_format total_amount}",
      "CURRENCY3=#{currency}",
      "TOTAL_ADVANCE_RECEIVED=#{standard_currency_format @db_total_advance_recieved}",
      "CURRENCY4=#{currency}",
      "TOTAL_DEDUCTION=#{standard_currency_format @db_total_deduction}",
      "CURRENCY5=#{currency}",
      "BALANCE_TO_BE_PAID=#{standard_currency_format db_net_total_amount}",
      "CURRENCY6=#{currency}",
      "NOTE=#{invoice_note}",
      "CREATED_BY=#{created_by}",
      "RESOLUTION_SUMMARY1=#{resolution_summary1}",
      "RESOLUTION_SUMMARY2=#{resolution_summary2}",
      "TOTAL_ERROR=#{@total_error}",
    ]

  end

  def ticket_bpm_headers(process_id, ticket_id, spare_part_id = nil, onloan_spare_part_id = nil)
    TicketSparePart
    WorkflowMapping

    @ticket = Ticket.find_by_id(ticket_id)

    if process_id.present? and @ticket.present?

      ticket_no  = "[#{@ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}]"

      customer_name = "#{@ticket.customer.name}".truncate(23)

      terminated = "[Terminated]" if @ticket.ticket_terminated

      re_open = "[Re-Open]" if @ticket.re_open_count > 0

      product_brand = "[#{@ticket.products.first.product_brand.name.truncate(13)}]"

      job_type = "[#{@ticket.job_type.name}]"

      ticket_type = "[#{@ticket.ticket_type.name} #{@ticket.onsite_type.try(:name)}]"

      regional = "[Regional]" if @ticket.regional_support_job

      repair_type = "[#{@ticket.ticket_repair_type.name}]" if @ticket.ticket_repair_type.code == "EX"

      delivery_stage = @ticket.ticket_deliver_units.any?{|d| !d.received} ? "[to-be collected]" : (@ticket.ticket_deliver_units.any?{|d| !d.delivered_to_sup} ? "[to-be delivered]" : "")

      custormer_approval_pending = "[Customer Approval Pending]" if @ticket.cached_ticket_estimations.any?{ |estimation| estimation.cust_approval_required and !estimation.cust_approved }

      parts_recieve_pending = "[Part Recieve Pending]" if @ticket.cached_ticket_spare_parts.any?{ |spare_part| spare_part.spare_part_status_action.code == "ISS" }

      hold = "[Hold]" if @ticket.status_hold

      not_started = "[Not Started]" if @ticket.ticket_status.code == "ASN"

      color_code = case
      when @ticket.ticket_status.code == "ASN"
        "red"
      when @ticket.status_hold
        "orange"
      when @ticket.cached_ticket_spare_parts.any?{ |spare_part| spare_part.spare_part_status_action.code == "ISS" }
        "blue"
      when @ticket.cached_ticket_estimations.any?{ |estimation| estimation.cust_approval_required and !estimation.cust_approved }
        "yellow"
      end

      @h1 = "color:#{color_code}|#{ticket_no}#{customer_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}#{delivery_stage}#{hold}#{parts_recieve_pending}#{not_started}#{custormer_approval_pending}"


      if spare_part_id.present?
        spare_part = @ticket.ticket_spare_parts.find_by_id(spare_part_id)
        store_part = spare_part.ticket_spare_part_store
        manufacture_part = spare_part.ticket_spare_part_manufacture
        non_stock_part = spare_part.ticket_spare_part_non_stock

        # store_part_name = (store_part && store_part.inventory_product) ? store_part.inventory_product.try(:description))

        if store_part and store_part.inventory_product
          spare_part_name = "[S: #{store_part.inventory_product.description.try :truncate, 18}]"

        elsif manufacture_part
          spare_part_name = "[M: #{spare_part.spare_part_description.truncate(18)}]"

        elsif non_stock_part
          spare_part_name = "[NS: #{non_stock_part.inventory_product.description.try :truncate, 18}]"
        end

        if spare_part_name
          @h2 = "#{ticket_no}#{customer_name}#{spare_part_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}"
        else
          @h2 = ""
        end

        if spare_part
          spare_part_name = "[#{spare_part.spare_part_no}-#{spare_part.spare_part_description.truncate(18)}]"
          @h3 = "#{ticket_no}#{customer_name}#{spare_part_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}"
        else
          @h3 = ""
        end

      end

      if onloan_spare_part_id.present?
        onloan_spare_part = @ticket.ticket_on_loan_spare_parts.find_by_id(onloan_spare_part_id)

        if onloan_spare_part and onloan_spare_part.inventory_product
          store_part_name = "[#{onloan_spare_part.inventory_product.description.try :truncate, 18}]"

          @h2 = "#{ticket_no}#{customer_name}#{store_part_name} (On-Loan) #{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}"
        else
          @h2 = ""
        end
      end

      found_process_id = WorkflowHeaderTitle.where(process_id: process_id)
      if found_process_id.present?
        found_process_id.first.update(h1: @h1, h2: @h2, h3: @h3)
      else
        WorkflowHeaderTitle.create(process_id: process_id, h1: @h1, h2: @h2, h3: @h3)
      end
    end

  end

  def standard_currency_format number
    number_with_precision number.to_f, separator: '.', delimiter: ',', precision: 2
  end
end