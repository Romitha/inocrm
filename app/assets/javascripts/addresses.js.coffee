window.Addresses =
  setup: ->
    @nested_form_addition()
    return

  nested_form_addition: ->
    $(document).on 'nested:fieldAdded', (event) ->
      field = event.field
      dateField = field.find('.date')