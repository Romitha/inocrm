json.array!(@tickets) do |ticket|
  json.extract! ticket, :id, :type, :status, :subject, :priority, :description, :deleted, :attachment, :organization_id, :department_id, :user_id
  json.url ticket_url(ticket, format: :json)
end
