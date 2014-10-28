window.Organizations =
  setup: ->
    @show_more_less()
    return

  show_more_less: ->
    if $(".panel-body").height() > 100
      $(".panel-body").removeClass("show-limit")
      $(".more_toggle").addClass("hide")
    else
      $(".panel-body").addClass("show-limit")
      $(".more_toggle").removeClass("hide")

  toggle_more: ->
    $(".panel-body").removeClass("show-limit")
    $(".hide_screen").remove()