window.QAndAs =
  setup: ->
    return

  coloring_row: ->
    $(".checked_row").each ->
      if $(@).is(":checked")
        $(@).parents().eq(1).addClass("success")
    return