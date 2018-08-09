count = 0

json.spare_parts @ticket_spare_part_manufactures do |ticket_spare_part_manufacture|
  count += 1
  json.index count
  json.event_no ticket_spare_part_manufacture.event_no
  json.event_closed_date ticket_spare_part_manufacture.issued_at.try(:strftime, INOCRM_CONFIG['short_date_format'])
  json.order_no ticket_spare_part_manufacture.order_no
  json.issued_at ticket_spare_part_manufacture.issued_at.try(:strftime, INOCRM_CONFIG['short_date_format'])
  json.part_no ticket_spare_part_manufacture.ticket_spare_part.spare_part_no
  json.spare_part_description ticket_spare_part_manufacture.ticket_spare_part.spare_part_description
  json.amount ticket_spare_part_manufacture.payment_expected_manufacture
  json.note ticket_spare_part_manufacture.ticket_spare_part.note
  json.ticket_no ticket_spare_part_manufacture.ticket_spare_part.ticket.support_ticket_no
  json.serial_no ticket_spare_part_manufacture.ticket_spare_part.ticket.products.first.serial_no
  json.part_id ticket_spare_part_manufacture.ticket_spare_part.id
  json.currency_id ticket_spare_part_manufacture.ticket_spare_part.ticket.products.first.product_brand.currency_id
  json.currency_code ticket_spare_part_manufacture.ticket_spare_part.ticket.products.first.product_brand.currency.code
end
