window.Organizations =
  setup: ->
    # @show_more_less()
    @enable_chosen()
    return

  show_more_less: ->
    if $(".panel-body").height() > 100
      $(".panel-body").addClass("show-limit")
      $(".more_toggle").removeClass("hide")
    else
      $(".panel-body").removeClass("show-limit")
      $(".hide_screen").remove()

  toggle_more: ->
    $(".panel-body").removeClass("show-limit")
    $(".hide_screen").remove()

  enable_chosen: ->
    $('.chosen-select').chosen
      allow_single_deselect: true
      no_results_text: 'No results matched'
      width: '100%'
  initiate_datepicker: ->
    $('.datepicker').datepicker
      format: "dd M, yyyy"
      todayBtn: true
      todayHighlight: true