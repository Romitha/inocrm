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

    contact_person = ticket.inform_cp == 2 ? ticket.contact_person2 : ticket.contact_person1
    [
      "DUPLICATE=#{ticket.ticket_print_count > 0 ? 'D' : ''}",
      "DATETIME=#{ticket.created_at.strftime(INOCRM_CONFIG['long_date_format']+' '+INOCRM_CONFIG['time_format'])}",
      "TICKET_REF=#{ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}",
      "COMPANY_NAME=#{ticket.customer.full_name}",
      "CONTACT_PERSON=#{contact_person.full_name}",
      "ADDRESS=#{ticket.customer.address1} #{ticket.customer.address2} #{ticket.customer.address3} #{ticket.customer.address4}",

      "TELPHONE=#{contact_person.contact_person_contact_types.find_by_contact_type_id(ContactType.find_by_fixedline(true).id).try(:value)}",
      "MOBILE=#{contact_person.contact_person_contact_types.find_by_contact_type_id(ContactType.find_by_mobile(true).id).try(:value)}",
      "EMAIL=#{contact_person.contact_person_contact_types.find_by_contact_type_id(ContactType.find_by_email(true).id).try(:value)}",

      "PRODUCT_BRAND=#{ticket.products.first.product_brand.name}",
      "PRODUCT_CATEGORY=#{ticket.products.first.category_full_name_index}",
      "MODEL_NO=#{ticket.products.first.model_no}",
      "SERIAL_NO=#{ticket.products.first.serial_no}",
      "PRODUCT_NO=#{ticket.products.first.product_no}",
      "PROBLEM_DESC1=#{ticket.problem_description.to_s[0..100]}",
      "PROBLEM_DESC2=#{ticket.problem_description.to_s[101..200]}",
      "WARRANTY=#{'X' if ticket.products.first.warranties.any?{|w| (w.start_at.to_date..w.end_at.to_date).include?(ticket.created_at.to_date)}}",
      "CHARGEABLE=#{'X' if ticket.cus_chargeable}",
      "NEED_POP=#{'X' if ticket.products.first.product_pop_status.present? and ticket.products.first.product_pop_status.code != 'NAP'}",
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
      "ACCESSORY_OTHER=#{ticket.other_accessories}",
      "LOGGED_BY=#{User.cached_find_by_id(ticket.logged_by).try(:full_name)}",
      "NOTE=#{ticket.note}",
    ]

  end

  def print_fsr_tag_value fsr #REQUEST_TYPE=PRINT_SPPT_FSR
    contact_person = fsr.ticket.inform_cp == 2 ? fsr.ticket.contact_person2 : fsr.ticket.contact_person1
    [
      "DUPLICATE=#{fsr.print_count > 0 ? 'D' : ''}",
      "FSR_NO=#{fsr.ticket_fsr_no.to_s.rjust(6, INOCRM_CONFIG['fsr_no_format'])}",
      "COMPANY_NAME=#{fsr.ticket.customer.full_name}",
      "ADDRESS=#{fsr.ticket.customer.address1} #{fsr.ticket.customer.address2} #{fsr.ticket.customer.address3} #{fsr.ticket.customer.address4}",
      "TELPHONE=#{fsr.ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Telephone"}.first.try(:value)}",
      "MOBILE=#{fsr.ticket.customer.contact_type_values.select{|c| c.contact_type.mobile}.first.try(:value)}",
      "CONTACT_PERSON=#{contact_person.full_name} (#{contact_person.contact_person_contact_types.select{|c| c.contact_type.mobile || c.contact_type.fixedline }.map { |c| c.contact_info }.join(', ')})",
      "TICKET_REF=#{fsr.ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}",
      "ENGINEER=#{fsr.ticket_engineer and fsr.ticket_engineer.user.full_name}",
      "SERIAL_NO=#{fsr.ticket.products.first.serial_no}",
      "PRODUCT_DETAILS=#{[fsr.ticket.products.first.product_brand.name, fsr.ticket.products.first.category_full_name_index, fsr.ticket.products.first.model_no, fsr.ticket.products.first.product_no].join(' / ')}",
      "PRODUCT_BRAND=#{fsr.ticket.products.first.product_brand.name}",
      "PRODUCT_CATEGORY=#{fsr.ticket.products.first.category_full_name_index}",
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
      "RECEIPT_NO=#{receipt.receipt_no.to_s.rjust(6, INOCRM_CONFIG['receipt_no_format'])}",
      "COMPANY_NAME=#{receipt.ticket.customer.full_name}",
      "TICKET_REF=#{receipt.ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}",
      "INVOICE_NO=#{ receipt.ticket_invoice and receipt.ticket_invoice.invoice_no.to_s.rjust(6, INOCRM_CONFIG['invoice_no_format'])}",
      "AMOUNT=#{standard_currency_format(receipt.amount)}",
      "DESCRIPTION=#{receipt.receipt_description.truncate(35)}",
      # "PAYMENT_TYPE=#{TicketPaymentReceivedType::TYPES.key(receipt.payment_type)}",
      "PAYMENT_TYPE=#{INOCRM_CONFIG['TicketPaymentReceivedType'].key(receipt.payment_type)}",
      "PAYMENT_NOTE=#{receipt.payment_note.to_s.try(:truncate, 35)}",
      "TYPE=#{receipt.ticket_payment_received_type.name}",
      "NOTE=#{receipt.note.to_s.truncate(70)}",
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
    mobile = customer.contact_type_values.select{|c| c.contact_type.mobile or c.contact_type.fixedline }.first.try(:value)
    serial_no = product.serial_no
    model_no = product.model_no
    product_brand = product.product_brand.name
    product_category = product.category_full_name_index
    special_note = ticket.note
    accessory1 = accessories.first.try(:accessory)
    accessory2 = accessories.second.try(:accessory)
    accessory3 = accessories.third.try(:accessory)
    accessory4 = accessories.fourth.try(:accessory)
    accessory5 = accessories.fifth.try(:accessory)
    accessory_other = ticket.other_accessories
    problem_des1 = ticket.problem_description
    resolution_summary1 = ticket.resolution_summary
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
      "Phone No :" => mobile,
      "Serial No :" => serial_no,
      "Product Brand :" => product_brand,
      "Model No :" => model_no,
      "Product Category :" => (product_category.present? ? [product_category.to_s[0..25], product_category[26..49]].compact : ''),
      "Special Notes :" => (special_note.present? ? [special_note.to_s[0..25], special_note.to_s[26..49], special_note.to_s[50..74]].compact : ''),
      "Accessories :" => [accessory1, accessory2, accessory3, accessory4, accessory5],

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
      "Other Accessories :" => (accessory_other.present? ? [accessory_other.to_s[0..25], accessory_other[26..49], accessory_other[50..74]].compact : ''),
      "Reported failure :" => (problem_des1.present? ? [problem_des1.to_s[0..31], problem_des1.to_s[32..63]].compact : ''),
      "Resolution :" => (resolution_summary1.present? ? [resolution_summary1.to_s[0..31], resolution_summary1.to_s[32..63]].compact : ''),
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
    company_name = ticket.customer.full_name
    contact_person = ticket.inform_cp == 2 ? ticket.contact_person2.full_name : ticket.contact_person1.full_name
    #contact_person = "#{ticket.contact_person1.full_name}"
    address1 = ticket.customer.address1
    address2 = ticket.customer.address2
    address3 = ticket.customer.address3
    address4 = ticket.customer.address4
    telephone = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Telephone"}.first.try(:value)
    mobile = ticket.customer.contact_type_values.select{|c| c.contact_type.mobile}.first.try(:value)
    fax = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Fax"}.first.try(:value)
    email = ticket.customer.contact_type_values.select{|c| c.contact_type.email}.first.try(:value)
    product_brand = ticket.products.first.product_brand.name
    product_category = ticket.products.first.category_full_name_index
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
    if quotation.canceled?
      canceled = "CANCELED" 
    else
      canceled = ""
    end
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
        item_code = estimation_part.ticket_spare_part.ticket_spare_part_store.present? ? (estimation_part.ticket_spare_part.ticket_spare_part_store.approved_inventory_product.try(:generated_item_code) or estimation_part.ticket_spare_part.ticket_spare_part_store.inventory_product.try(:generated_item_code)) : ""

        totalprice = ticket_estimation.approval_required ? estimation_part.approved_estimated_price.to_f : estimation_part.estimated_price.to_f

        quantity = ( ( estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock ).try(:approved_quantity) or ( estimation_part.ticket_spare_part.ticket_spare_part_manufacture or estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock ).try(:requested_quantity) )

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
        quantity = 1

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
      "CANCELED=#{canceled}",
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
    invoice_date = invoice.created_at.strftime(INOCRM_CONFIG['long_date_format'])
    invoice_time = invoice.created_at.strftime(INOCRM_CONFIG['time_format'])
    ticket_ref = ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])
    company_name = ticket.customer.full_name
    contact_person = "#{ticket.contact_person1.full_name}"
    address1 = ticket.customer.address1
    address2 = ticket.customer.address2
    address3 = ticket.customer.address3
    address4 = ticket.customer.address4
    vat_no = ticket.customer.vat_no
    svat_no = ticket.customer.svat_no
    invoice_type = invoice.invoice_type.try(:print_name)
    telephone = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Telephone"}.first.try(:value)
    mobile = ticket.customer.contact_type_values.select{|c| c.contact_type.mobile}.first.try(:value)
    fax = ticket.customer.contact_type_values.select{|c| c.contact_type.name == "Fax"}.first.try(:value)
    email = ticket.customer.contact_type_values.select{|c| c.contact_type.email}.first.try(:value)
    product_brand = ticket.products.first.product_brand.name
    product_category = ticket.products.first.category_full_name_index
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
    delivery_address = invoice.delivery_address
    so_number = invoice.so_number
    po_number = invoice.po_number
    delivery_number_date = invoice.delivery_number_date
    if invoice.canceled?
      canceled = "CANCELED" 
    else
      canceled = ""
    end
    total_amount = 0
    net_total_amount = 0
    currency = invoice.currency.try(:code)
    total_advance_recieved = 0
    total_deduction = 0
    balance_tobe_paid = 0
    db_net_total_amount = 0

    if invoice.print_exchange_rate.present?
      exchange_rate = invoice.print_exchange_rate.to_f
    else
      exchange_rate = 1
    end
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


        if invoice.print_currency.try(:code) != ticket_invoice_estimation.ticket_estimation.currency.try(:code)
          currency_1 = invoice.print_currency.try(:code)
          unit_price *= exchange_rate
          totalprice *= exchange_rate
        end

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => totalprice, "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        estimation_external.ticket_estimation_external_taxes.each do |ticket_estimation_external_tax|
          item_index += 1
          description = "#{ticket_estimation_external_tax.tax.tax} (#{ticket_estimation_external_tax.tax_rate})"
          unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? ticket_estimation_external_tax.approved_tax_amount.to_f : ticket_estimation_external_tax.estimated_tax_amount.to_f

          totalprice = unit_price
          total_amount += totalprice
          net_total_amount += totalprice
        if invoice.print_currency.try(:code) != ticket_invoice_estimation.ticket_estimation.currency.try(:code)
          currency_1 = invoice.print_currency.try(:code)
          totalprice *= exchange_rate
        end
          repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
        end

      end

      if ticket_invoice_estimation.ticket_estimation.ticket_estimation_parts.present?
        estimation_part = ticket_invoice_estimation.ticket_estimation.ticket_estimation_parts.first
        item_index += 1
        description = "Part No: #{estimation_part.ticket_spare_part.spare_part_no} #{estimation_part.ticket_spare_part.spare_part_description}" + "#{' (Warr: ' + estimation_part.warranty_period.to_s + ' M)' if estimation_part.warranty_period.present? }"
        item_code = estimation_part.ticket_spare_part.ticket_spare_part_store.present? ? (estimation_part.ticket_spare_part.ticket_spare_part_store.approved_inventory_product.try(:generated_item_code) || estimation_part.ticket_spare_part.ticket_spare_part_store.inventory_product.try(:generated_item_code)) : ""

        totalprice = ticket_invoice_estimation.ticket_estimation.approval_required ? estimation_part.approved_estimated_price.to_f : estimation_part.estimated_price.to_f

        quantity = ( ( estimation_part.ticket_spare_part.ticket_spare_part_store or estimation_part.ticket_spare_part.ticket_spare_part_non_stock).try(:approved_quantity ) or 1 )

        unit_price = totalprice / quantity
        total_amount += totalprice
        net_total_amount += totalprice

        if invoice.print_currency.try(:code) != ticket_invoice_estimation.ticket_estimation.currency.try(:code)
          currency_1 = invoice.print_currency.try(:code)
          unit_price *= exchange_rate
          totalprice *= exchange_rate
        end

        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => item_code, "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        estimation_part.ticket_estimation_part_taxes.each do |ticket_estimation_part_tax|
          item_index += 1
          description = "#{ticket_estimation_part_tax.tax.tax} (#{ticket_estimation_part_tax.tax_rate})"

          unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? ticket_estimation_part_tax.approved_tax_amount.to_f : ticket_estimation_part_tax.estimated_tax_amount.to_f
      
          totalprice = unit_price
          total_amount += totalprice
          net_total_amount += totalprice
          if invoice.print_currency.try(:code) != ticket_invoice_estimation.ticket_estimation.currency.try(:code)
            currency_1 = invoice.print_currency.try(:code)
            totalprice *= exchange_rate
          end
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

        if invoice.print_currency.try(:code) != ticket_invoice_estimation.ticket_estimation.currency.try(:code)
          currency_1 = invoice.print_currency.try(:code)
          unit_price *= exchange_rate
          totalprice *= exchange_rate
        end
        repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => quantity, "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join

        ticket_estimation_additional.ticket_estimation_additional_taxes.each do |ticket_estimation_additional_tax|
          item_index += 1
          description = "#{ticket_estimation_additional_tax.tax.tax} (#{ticket_estimation_additional_tax.tax_rate})"
          unit_price = ticket_invoice_estimation.ticket_estimation.approval_required ? ticket_estimation_additional_tax.approved_tax_amount.to_f : ticket_estimation_additional_tax.estimated_tax_amount.to_f
        
          totalprice = unit_price
          total_amount += totalprice
          net_total_amount += totalprice
          if invoice.print_currency.try(:code) != ticket_invoice_estimation.ticket_estimation.currency.try(:code)
            currency_1 = invoice.print_currency.try(:code)
            totalprice *= exchange_rate
          end
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
      if invoice.print_currency.try(:code) != ticket_invoice_terminate.act_terminate_job_payment.currency.try(:code)
        currency_1 = invoice.print_currency.try(:code)
        unit_price *= exchange_rate
        totalprice *= exchange_rate
      end
      repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => standard_currency_format(unit_price), "CURRENCY1" => currency_1, "TOTAL_PRICE" => standard_currency_format(totalprice), "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
    end

    invoice.ticket_invoice_advance_payments.each do |ticket_invoice_advance_payment|
      currency_1 = ticket_invoice_advance_payment.ticket_payment_received.currency.code
      
      item_index += 1
      description = "Advanced Payment Received on : #{ticket_invoice_advance_payment.ticket_payment_received.received_at.strftime(INOCRM_CONFIG['long_date_format'])}"
      unit_price = -ticket_invoice_advance_payment.ticket_payment_received.amount.to_f
      totalprice = unit_price
      total_advance_recieved += totalprice
      net_total_amount += totalprice
      if invoice.print_currency.try(:code) != ticket_invoice_advance_payment.ticket_payment_received.currency.try(:code)
        currency_1 = invoice.print_currency.try(:code)
        totalprice *= exchange_rate
      end
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
      if invoice.print_currency.try(:code) != invoice.currency.try(:code)
        currency_1 = invoice.print_currency.try(:code)
        totalprice *= exchange_rate
      end
      repeat_data += {"INDEX_NO" => item_index, "ITEM_CODE" => "", "DESCRIPTION" => description, "QUANTITY" => "", "UNIT_PRICE" => "", "CURRENCY1" => "", "TOTAL_PRICE" => totalprice, "CURRENCY2" => currency_1}.map { |k, v| "#{k}=#{v}$|#" }.join
    end

    @db_total_amount = invoice.total_amount
    db_net_total_amount = invoice.net_total_amount
    @db_total_advance_recieved = -invoice.total_advance_recieved
    @db_total_deduction = -invoice.total_deduction
    if (db_net_total_amount != net_total_amount) or (@db_total_advance_recieved != total_advance_recieved) or (@db_total_deduction != total_deduction)
      @total_error="Calculation Error In Totals: net_total_amount=#{net_total_amount} total_advance_recieved=#{total_advance_recieved} total_deduction=#{total_deduction}"
    end
    if invoice.print_currency.try(:code) != invoice.currency.try(:code)
      currency = invoice.print_currency.try(:code)
      total_amount *= exchange_rate
      @db_total_advance_recieved *= exchange_rate
      @db_total_deduction *= exchange_rate
      db_net_total_amount *= exchange_rate
    end
    [
      "DUPLICATE_D=#{ticket.ticket_complete_print_count > 0 ? 'D' : ''}",
      "CANCELED=#{canceled}",
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
      "VAT_NUMBER=#{vat_no}",
      "SVAT_NUMBER=#{svat_no}",
      "INVOICE_TYPE=#{invoice_type}",
      "TICKET_REF=#{ticket_ref}",
      "CREATED_DATE=#{invoice_date}",
      "CREATED_TIME=#{invoice_time}",
      "PAYMENT_TERM=#{payment_term}",
      "DELIVERY_ADDRESS=#{delivery_address}",
      "SO_NUMBER=#{so_number}",
      "PO_NUMBER=#{po_number}",
      "DELIVERY_NUMBER_DATE=#{delivery_number_date}",
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
    parameter_holder = {}

    if process_id.present? and @ticket.present?

      ticket_spare_parts = @ticket.ticket_spare_parts.reload
      ticket_estimations = @ticket.ticket_estimations.reload

      ticket_no  = "[#{@ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG['ticket_no_format'])}]"

      customer_name = "#{@ticket.customer.name}".truncate(23)

      terminated = "[Terminated]" if @ticket.ticket_terminated

      re_open = "[Re-Open]" if @ticket.re_open_count > 0

      # product_brand = "[#{@ticket.products.first.product_brand.name.truncate(13)}]"
      product_brand = "[#{@ticket.products.first.product_brand.name.truncate(13)}/#{@ticket.products.first.category1_name.truncate(10)}]" #[Brand Name/Product category1]

      job_type = "[#{@ticket.job_type.name}]"

      ticket_type = "[#{@ticket.ticket_type.name} #{@ticket.onsite_type.try(:name)}]"

      regional = "[Regional]" if @ticket.regional_support_job

      repair_type = "[#{@ticket.ticket_repair_type.name}]" if @ticket.ticket_repair_type.code == "EX"

      # delivery_stage = @ticket.ticket_deliver_units.any?{|d| !d.received} ? "[to-be collected]" : (@ticket.ticket_deliver_units.any?{|d| !d.delivered_to_sup} ? "[to-be delivered]" : "")
      tdu = @ticket.ticket_deliver_units.last
      if tdu.present?
        delivery_stage =  !tdu.delivered_to_sup ? "[to-be delivered]" : (!tdu.collected ? "[to-be collected]" : "")
      end

      # File.open(Rails.root.join("bug_file.txt"), "w+"){|file| file.write("ticket_deliver_units: #{tdu.inspect}"); file.close}

      custormer_approval_pending = "[Customer Approval Pending]" if ticket_estimations.any?{ |estimation| estimation.cust_approval_required and !estimation.cust_approved_at.present? }

      hold = "[Hold]" if @ticket.status_hold

      not_started = "[Not Started]" if @ticket.ticket_status.code == "ASN"

      ticket_spare_parts.each do |spare_part|
        unless spare_part.spare_part_status_action.code == 'CLS' or spare_part.received_eng

          if spare_part.request_from == "M" and ((!spare_part.cus_chargeable_part and spare_part.spare_part_status_action.manufacture_type_index >= 1) or (spare_part.cus_chargeable_part and spare_part.spare_part_status_action.manufacture_ch_type_index >= 4))

            parameter_holder[:pending_mf_parts_count] = parameter_holder[:pending_mf_parts_count].to_i + 1

          end

          if spare_part.request_from == "S" and ((!spare_part.cus_chargeable_part and spare_part.spare_part_status_action.store_nc_type_index >= 1) or (spare_part.cus_chargeable_part and spare_part.spare_part_status_action.store_ch_type_index >= 4))

            parameter_holder[:pending_st_sparts_count] = parameter_holder[:pending_st_sparts_count].to_i + 1

          end
        end

        if ['ISS'].include? spare_part.spare_part_status_action.code
          parameter_holder[:parts_issued_count] = parameter_holder[:parts_issued_count].to_i + 1
        end

        if ['CLT', 'RCS'].include? spare_part.spare_part_status_action.code
          parameter_holder[:mf_parts_collected_count] = parameter_holder[:mf_parts_collected_count].to_i + 1
        end
      end

      @ticket.ticket_on_loan_spare_parts.each do |onloan_spare_part|
        unless (onloan_spare_part.spare_part_status_action.code == 'CLS') or onloan_spare_part.received_eng
          parameter_holder[:pending_onloan_parts_count] = parameter_holder[:pending_onloan_parts_count].to_i + 1 if (onloan_spare_part.spare_part_status_action.on_loan_type_index >= 1)
        end
        if ['ISS'].include? onloan_spare_part.spare_part_status_action.code
          parameter_holder[:parts_issued_count] = parameter_holder[:parts_issued_count].to_i + 1
        end
      end

      pending_estimation_count = ticket_estimations.to_a.sum{|estimation| estimation.estimation_status.code == 'RQS' ? 1 : 0 }

      pending_unit_collect = @ticket.ticket_deliver_units.any?{|deliver_unit| !deliver_unit.delivered_to_sup }

      h_pending_estimation = "[ #{pending_estimation_count} Estimations Pending]" if pending_estimation_count > 0
      h_pending_mf_parts = "[ #{parameter_holder[:pending_mf_parts_count]} MF Parts Pending]" if parameter_holder[:pending_mf_parts_count].to_i > 0
      h_pending_st_parts = "[ #{parameter_holder[:pending_st_sparts_count]} ST Parts Pending]" if parameter_holder[:pending_st_sparts_count].to_i > 0
      h_pending_onloan_parts = "[ #{parameter_holder[:pending_onloan_parts_count]} Onloan Parts Pending]" if parameter_holder[:pending_onloan_parts_count].to_i > 0
      h_pending_unit_collect = "[ Unit Receive Pending ]" if pending_unit_collect
      h_mf_parts_collected = "[ #{parameter_holder[:mf_parts_collected_count]} MF Parts Collected]" if parameter_holder[:mf_parts_collected_count].to_i > 0
      h_parts_issued = "[ #{parameter_holder[:parts_issued_count]} Parts Issued]" if parameter_holder[:parts_issued_count].to_i > 0


      color_code = case
      when @ticket.ticket_status.code == "ASN"
        "red"
      when @ticket.status_hold
        "orange"
      when ticket_spare_parts.any?{ |spare_part| spare_part.spare_part_status_action.code == "ISS" }
        "blue"
      when ticket_estimations.any?{ |estimation| estimation.cust_approval_required and !estimation.cust_approved }
        "yellow"
      end
      h1_color_code = h2_color_code = h3_color_code = color_code


      @h1 = "color:#{h1_color_code}|#{ticket_no}#{customer_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}#{delivery_stage}#{hold}#{not_started}#{custormer_approval_pending}#{h_pending_estimation}#{h_pending_mf_parts}#{h_pending_st_parts}#{h_pending_onloan_parts}#{h_mf_parts_collected}#{h_parts_issued}#{h_pending_unit_collect}"
      @h3_sub = ""

      spare_part = @ticket.ticket_spare_parts.find_by_id(spare_part_id)
      # File.open(Rails.root.join("error.txt"), "w") do |io|
      #   io << spare_part.inspect
      #   io.close

      # end

      if spare_part.present?
        if spare_part
          store_part = spare_part.ticket_spare_part_store
          manufacture_part = spare_part.ticket_spare_part_manufacture
          non_stock_part = spare_part.ticket_spare_part_non_stock
        end

        if store_part and store_part.inventory_product
          spare_part_name = "[S: #{store_part.inventory_product.description.try :truncate, 18}]"

          inventory = Inventory.where(product_id: store_part.approved_inv_product_id, store_id: store_part.approved_store_id).first
          if inventory.present? and inventory.available_quantity >= store_part.approved_quantity
            part_available = "[Parts Available]"
            h2_color_code = "blue"
          end

        elsif manufacture_part
          spare_part_name = "[M: #{spare_part.spare_part_no}-#{spare_part.spare_part_description.truncate(18)} Evn No:#{manufacture_part.event_no}]"
          if ["ORD", "CLT", "RCS"].include?(spare_part.spare_part_status_action.code)
            part_next_status = SparePartStatusAction.find_by_manufacture_type_index(spare_part.spare_part_status_action.manufacture_type_index + 1)

            @h3_sub = " (#{part_next_status.name_next}) " if part_next_status.present?
          end

          if (spare_part.spare_part_status_action.manufacture_type_index < 3) and (manufacture_part.order_pending == 1)
            @h3_sub = " [Order Updated][Evn No:#{manufacture_part.event_no}]#{@h3_sub}"
          else
            @h3_sub = " [Evn No:#{manufacture_part.event_no}]#{@h3_sub}"
          end

          h3_color_code = "blue" if (spare_part.spare_part_status_action.code == "CLT" or spare_part.spare_part_status_action.code == "RCS")

        elsif non_stock_part
          spare_part_name = "[NS: #{non_stock_part.inventory_product.description.try :truncate, 18}]"
        end

        if spare_part_name
          @h2 = "color:#{h2_color_code}|#{ticket_no}#{customer_name}#{spare_part_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}#{hold}#{part_available}"
        else
          @h2 = ""
        end

        if spare_part
          #spare_part_name = "[#{spare_part.spare_part_no}-#{spare_part.spare_part_description.truncate(18)}]"
          @h3 = "color:#{h3_color_code}|#{@h3_sub}#{ticket_no}#{customer_name}#{spare_part_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}#{hold}"
        else
          @h3 = ""
        end

      end

      onloan_spare_part = @ticket.ticket_on_loan_spare_parts.find_by_id(onloan_spare_part_id)
     # onloan_spare_part = TicketOnLoanSparePart.find_by_id(onloan_spare_part_id)
      if onloan_spare_part.present?

        if onloan_spare_part and onloan_spare_part.inventory_product
          store_part_name = "[#{onloan_spare_part.inventory_product.description.try :truncate, 18}]"

          @h2 = "color:#{h2_color_code}|#{ticket_no}#{customer_name}#{store_part_name} (On-Loan) #{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}#{hold}"
        else
          @h2 = ""
        end
      end

      found_process = WorkflowHeaderTitle.where(process_id: process_id)
      if found_process.present?
        found_process.first.update(h1: @h1, h2: @h2, h3: @h3)
      else
        WorkflowHeaderTitle.create(process_id: process_id, h1: @h1, h2: @h2, h3: @h3)
      end
    end

  end

  def standard_currency_format number
    number_with_precision number.to_f, separator: '.', delimiter: ',', precision: 2
  end
end