window.Tickets =
  setup: ->
    @sample()
    return

  sample: ->
    $(".find_customer").click ->
      find_customer = $(@).val()
      $.post("/tickets/find_customer", {find_by: find_customer}, (data)->
        $('#load_for_customer_select_box').html Mustache.to_html($('#load_for_customer_select_box_mustache').html(), data)
      ).done( (date)->
      ).fail( ->
        alert "There are some errors. please try again"
      )