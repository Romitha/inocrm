json.customers @customers do |customer|
	json.email customer.email
	json.id customer.id
end
json.find_by @label
json.csrf_token @csrf_token