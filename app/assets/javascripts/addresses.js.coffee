window.Addresses =
  setup: ->
    @nested_form_addition()
    @handlebar_template_render("#entry-template", {title: "My New Post", body: "This is my first post!"}, "#sample-handlebar")
    return

  nested_form_addition: ->
    $(document).on 'nested:fieldAdded', (event) ->
      field = event.field
      dateField = field.find('.date')

  handlebar_template_render: (template_id, context, output_template_id)->
    source   = $(template_id).html()
    # $("#entry-template").remove()
    template = Handlebars.compile(source)

    context = context
    html    = template(context)
    $(output_template_id).html(html)
