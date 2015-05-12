module AddressesHelper

  def panels(options = {}, &block)
    opt = options
    content_tag :div, class: "panel panel-#{opt[:panel_type]}" do
      (opt[:header_content] ? content_tag(:div, opt[:header_content], class: "panel-heading") : ''.html_safe)+
      content_tag(:div, class: "panel-body", &block)+
      (opt[:footer_content] ? content_tag(:div, opt[:footer_content], class: "panel-footer") : ''.html_safe)
    end
  end

  def initiate_table(options={}, &block)
    opt = options
    content_tag :table, class: "table table-responsive #{opt[:table_type]}", &block
  end

  def table_header(header_array)
    content_tag :thead do
      content_tag :tr do
        header_array.map{|h| content_tag :th, h}.join.html_safe
      end
    end
  end

  def table_body(body_array)
    content_tag :tbody do
      content_tag :tr do
        body_array.map do |b|
          if b.is_a?(Hash)
            content_tag :td, b[:content], b.except(:content)
          else
            content_tag :td, b
          end

        end.join.html_safe
      end
    end
  end

  def tab_panel options={}, &block
    content_tag :div, role: "tabpanel", &block
  end

  def tab_nav_tab options={}, nav_tab_array # {home: {active_class: "active", content: "Home"}, }
    content_tag :ul, role: "tablist", class: "nav nav-tabs #{options[:class]}", id: "#{options[:id]}" do
      nav_tab_array.collect{|k, v| content_tag(:li, class: v[:active_class], role: "presentation"){ link_to v[:content], "##{k.to_s}", role: "tab", "aria-controls" => k.to_s}}.join.html_safe      
    end
  end

  def tab_content options={}, &block
    content_tag :div, class: "tab-pane #{options[:active_class]}", role: "tabpanel", id: "#{options[:tabpointer]}", &block
  end
end