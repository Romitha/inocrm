window.Organizations =
  setup: ->
    @enable_chosen()
    @load_vat_number_option()
    # @toggle_tapbar()
    @organization_logo_upload()
    @chosen_select_disable_search()
    @dealer_type_check()
    @live_search_organization()
    @credit_allow()
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
    return

  chosen_select_disable_search: ->
    $('.chosen-select_disable_search').chosen
      disable_search: true
      width: '100%'
    return

  initiate_datepicker: ->
    $('.datepicker').datepicker
      format: "yyyy-mm-dd"
      todayBtn: true
      todayHighlight: true

  load_vat_number_option: ->
    $("#relate_id").change ->
      $('#load_vat_number_option_render').empty()

    $("#parent_member_for_vat_number").change ->
      relation_organization_id = $("#relate_id").data("organizationId")
      selected_organization_id = $("#relate_id :selected").val()
      if $(@).val()== "parent"
        $.post("/organizations/#{relation_organization_id}/option_for_vat_number", {relation_organization_id: relation_organization_id, selected_organization_id: selected_organization_id}, (data)->
          $('#load_vat_number_option_render').html Mustache.to_html($('#vat_number_output').html(), data)
        ).done( (date)->
        ).fail( ->
          alert "There are some errors. please try again"
        )
      else
        $('#load_vat_number_option_render').empty()

  toggle_tapbar: ->
    $('.nav-tabs a').click (e) ->
      e.preventDefault()
      $(@).tab('toggle')

  dealer_type_check: ->
    $(".dealer_type_check").each ->
      enable_save = false
      if !$(@).is(":checked")
        enable_save = true
      if enable_save
        $("#save_dealer_type").removeClass("hide")

  organization_logo_upload: ->
    $("#organization_logo").fileupload
      url: '/organizations/temp_save_user_profile_image'
      type: "PATCH"
      maxFileSize: 1000000
      dataType: "json"
      autoUpload: false
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png)$/i
        maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          if maxsize > file.size
            data.context = $(tmpl('organization_attachment_upload_tmpl', file))
            $(".organization_attachment_wrapper").html(data.context)
            data.submit()
            jqXHR = data.submit().complete( (result, textStatus, jqXHR)->
              setTimeout (->
                $('#autoloadable_prepend').html Mustache.to_html($('#load_files').html(), result.responseJSON)
                $(".organization_attachment_wrapper").empty()
                return
              ), 3000
            )

          else
            alert "Your image file is with #{file.size}KB is exceeding than limited size of #{maxsize}KB. Please select other image file not exceeding 1MB"
        else
          alert("#{file.name} is not a recommended file format")
      progress: (e, data) ->
        $(".screener").addClass("fade")
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          # data.context.find(".progress-bar").css("width", progress+"%").html(progress+"%")
          data.context.find(".progress-bar").css("width", progress+"%").attr("aria-valuenow", "#{progress}").html(progress+"%")
          # if progress==100
          #   # window.location.reload()
          #   console.log "uploaded"
      done: (e, data) ->
        $(".screener").removeClass("fade")
        # console.log data#.responseJSON
        $("#organization_upload_logo").html Mustache.to_html($('#load_logo').html(), data)

      fail: (e, data) ->
        if data.textStatus == 401
          console.log data.textStatus

  live_search_organization: ->
    options = {
      valueNames: [ 'organization_name', 'short_name', 'vat_number', 'industry_type' ]
      listClass: "organization_list"
      searchClass: "search"
    }
    organizationList = new List('organizations_search_initialization', options)

  credit_allow: ->
    $(".credit_allow").click ->
      if $(@).is(":checked")
        $(".credit_allow_control").removeClass("hide")
      else
        $(".credit_allow_control").addClass("hide")
        $(".credit_allow_control input").val("")