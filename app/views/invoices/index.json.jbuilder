json.array!(@invoices) do |invoice|
  json.extract! invoice, :id, :invoice_number, :paid, :total, :balance, :date, :due_date
  json.url invoice_url(invoice, format: :json)
end
