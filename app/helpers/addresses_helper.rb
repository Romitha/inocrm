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
end