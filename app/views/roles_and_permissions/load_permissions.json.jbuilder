# json.rpermissions(@rpermissions, :resource)

json.rpermissions @rpermissions do |rpermission|
  json.id rpermission.id
  json.name rpermission.name
  json.checked (@role.rpermission_ids.include?(rpermission.id) ? 'checked' : '')
end