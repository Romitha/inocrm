window.Departments =
  setup: ->
    @show_more()
    return

  show_more: ->
    $(".toggle_deparment_form").hide()
    $('#demote_org_as_dep').change ->
      if @checked
        $(".toggle_deparment_form").show()
      else
        $(".toggle_deparment_form").hide()
      return