module AddressesHelper

  def panels(options = {}, &block)
    opt = options
    content_tag :div, class: "panel panel-#{opt[:panel_type]}" do
      (opt[:header_content] ? content_tag(:div, opt[:header_content], class: "panel-heading") : ''.html_safe)+
      content_tag(:div, class: "panel-body", &block)+
      (opt[:footer_content] ? content_tag(:div, opt[:footer_content], class: "panel-footer") : ''.html_safe)
    end
  end

  def collapse_wrapper(options = {}, &block)
    opt = options
    content_tag(:div, class: "panel-group", id: "#{opt[:collapse_id]}", role: "tablist", "aria-multiselectable"=>"true", &block)
  end

  def collapse(options = {}, &block)
    opt = options
    content_tag :div, class: "panel panel-#{opt[:collapse_type] || 'default'}" do
      (content_tag :div, class: "panel-heading", role: "tab", id: opt[:labelledby] do
        content_tag :h4, class: "panel-title" do
          link_to (opt[:header_content] || "insert header"),"##{opt[:collapse_link]}", class: "collapsed", aria: {controls: opt[:collapse_link], expanded: "false"}, data: {parent: "##{opt[:collapse_id]}", toggle: "collapse"}, role: "button"
        end
      end)+
      (content_tag :div, id: opt[:collapse_link], class: "panel-collapse collapse #{opt[:collapse_in]}", role: "tabpanel", aria: {labelledby: opt[:labelledby], expanded: "false"} do
        content_tag(:div, class: "panel-body", &block)
      end)
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

  def multi_table_body &block
    content_tag :tbody, &block
  end

  def multi_table_row body_array
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

  def tab_panel options={}, &block
    content_tag :div, role: "tabpanel", &block
  end

  def tab_nav_tab options={}, nav_tab_hash # {home: {active_class: "active", content: "Home"}, }
    content_tag :ul, role: "tablist", class: "nav nav-tabs #{options[:class]}", id: "#{options[:id]}" do
      nav_tab_hash.collect{|k, v| content_tag(:li, class: v[:active_class], role: "presentation"){ link_to v[:content], "##{k.to_s}", role: "tab", "aria-controls" => k.to_s, data: {toggle: "tab"}.merge((v[:data] || {})), class: v[:link_class], id: v[:link_id]}}.join.html_safe
    end
  end

  def tab_content options={}, &block
    content_tag :div, class: "tab-pane #{options[:active_class]}", role: "tabpanel", id: "#{options[:tabpointer]}", &block
  end
end