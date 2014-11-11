module MustacheTemplateHandler
  def self.call(template)
  	haml = "Haml::Engine.new(#{template.source.inspect}).render"
    if template.locals.include? 'mustache'
      # "Mustache.render(#{template.source.inspect}, mustache).html_safe"
      "Mustache.render(#{haml}, mustache).html_safe"
    else
      "#{haml}.html_safe"
    end
  end
end

ActionView::Template.register_template_handler(:mustache, MustacheTemplateHandler)