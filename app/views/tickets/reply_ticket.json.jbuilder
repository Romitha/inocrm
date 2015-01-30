if @result
	json.subject @result.subject
	json.link_with_image link_to image_tag((@result.agent.avatar.try(:url) || "no_image.jpg"), alt: @result.agent.full_name, class: "media-object"), profile_user_path(@result.agent), target: "_blank"
	json.history @result.history
	json.content simple_format(@result.content)
else
	json.error @error
end