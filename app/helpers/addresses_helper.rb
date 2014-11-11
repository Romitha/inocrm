module AddressesHelper

	def panels(options = {}, &block)
		opt = options
		content_tag :div, class: "panel panel-#{opt[:panel_type]}" do
			(opt[:header_content] ? content_tag(:div, opt[:header_content], class: "panel-heading") : ''.html_safe)+
			content_tag(:div, class: "panel-body", &block)+
			(opt[:footer_content] ? content_tag(:div, opt[:footer_content], class: "panel-footer") : ''.html_safe)
		end
	end
end