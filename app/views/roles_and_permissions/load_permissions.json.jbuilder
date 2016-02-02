# json.rpermissions(@rpermissions, :resource)

json.rpermissions @rpermissions do |rpermission|
	json.resource rpermission[:resource]
	json.value rpermission[:value] do |value|
		json.id value[:id]
		json.checked value[:checked]
		json.name value[:name]
		json.resource value[:resource]
	end
end