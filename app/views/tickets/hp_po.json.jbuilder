count = 0
json.products @products do |product|
  json.tickets product.tickets do |ticket|
    json.ticket_currency_id ticket.base_currency_id
    json.spare_parts ticket.ticket_spare_parts do |spare_part|
      count += 1
      json.index count
      json.event_no spare_part.ticket_spare_part_manufacture.try(:event_no)
      json.event_closed_date spare_part.ticket_spare_part_manufacture.try(:issued_at).try(:strftime, "%Y-%m-%d")
      json.order_no spare_part.ticket_spare_part_manufacture.try(:order_no)
      json.issued_at spare_part.ticket_spare_part_manufacture.try(:issued_at).try(:strftime, "%Y-%m-%d")
      json.part_no spare_part.ticket_spare_part_manufacture.try(:spare_part_id)
      json.spare_part_description spare_part.try(:spare_part_description)
      json.note simple_format spare_part.try(:note)
      json.ticket_no spare_part.ticket_id.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"])
      json.serial_no spare_part.try(:spare_part_no)
      json.part_id spare_part.id
      json.note spare_part.note  
    end
  end
end