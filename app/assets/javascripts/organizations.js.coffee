window.Organizations =
  setup: ->
    @enable_chosen()
    @load_vat_number_option()
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

  load_vat_number_option: ->
    $("#parent_member_for_vat_number").change ->
      relation_organization_id = $("#relate_id").data("organizationId")
      selected_organization_id = $("#relate_id :selected").val()
      $.post("/organizations/#{relation_organization_id}/option_for_vat_number", {relation_organization_id: relation_organization_id, selected_organization_id: selected_organization_id}, (data)->
        $('#load_vat_number_option_render').html Mustache.to_html($('#vat_number_output').html(), data)
      ).done( (date)->
      ).fail( ->
        alert $(@).data("organization-id")
      )
    $("#relate_id").change ->
      alert "ok"
      # $('#load_vat_number_option_render').empty()