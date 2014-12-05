$ ->
	$("#load_permissions").change ->
		organization_id = $(@).data("organization-id")
		role_id = $(@).val()
		$.post("/organizations/#{organization_id}/roles_and_permissions/#{role_id}/load_permissions", {organization_id: organization_id, role_id: role_id}, (data)->
			$('#load_permissions_json_render').html Mustache.to_html($('#load_permissions_output').html(), data)
		).done( (date)->
		).fail( ->
			alert $(@).data("organization-id")
		)