count = 0
json.products @products do |product|
  json.tickets product.tickets do |ticket|
    json.ticket_currency_id ticket.base_currency_id
    json.spare_parts ticket.ticket_spare_parts do |spare_part|
      if spare_part.ticket_spare_part_manufacture.try(:bundled) and spare_part.ticket_spare_part_manufacture.try(:po_required) and not spare_part.ticket_spare_part_manufacture.try(:po_completed)
        count += 1
        json.index count
        json.event_no spare_part.ticket_spare_part_manufacture.try(:event_no)
        json.event_closed_date spare_part.ticket_spare_part_manufacture.try(:issued_at).try(:strftime, INOCRM_CONFIG['short_date_format'])
        json.order_no spare_part.ticket_spare_part_manufacture.try(:order_no)
        json.issued_at spare_part.ticket_spare_part_manufacture.try(:issued_at).try(:strftime, INOCRM_CONFIG['short_date_format'])
        json.part_no spare_part.ticket_spare_part_manufacture.try(:spare_part_id)
        json.spare_part_description spare_part.try(:spare_part_description)
        json.amount spare_part.ticket_spare_part_manufacture.try(:payment_expected_manufacture)
        json.note simple_format spare_part.try(:note)
        json.ticket_no spare_part.ticket.support_ticket_no
        json.serial_no spare_part.try(:spare_part_no)
        json.part_id spare_part.id
        json.note spare_part.note
      end
    end
  end
end