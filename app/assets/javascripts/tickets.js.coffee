window.Tickets =
  setup: ->
    @load_customer()
    @ticket_attachment_upload()
    @prevent_enter()
    @check_submit()
    return

  chosen_select: ->
    $('.chosen-select').chosen
      allow_single_deselect: true
      no_results_text: 'No results matched'
      width: '100%'

  load_customer: ->
    $(".find_customer").click ->
      find_customer = $(@).val()
      $.post("/tickets/find_customer", {find_by: find_customer}, (data)->
        $('#load_for_customer_select_box').html Mustache.to_html($('#load_for_customer_select_box_mustache').html(), data)
      ).done( (date)->
        $('.chosen-select').chosen
          allow_single_deselect: true
          no_results_text: 'No results matched'
          width: '100%'
      ).fail( ->
        alert "There are some errors. please try again"
      )

  ticket_attachment_upload: ->
    $("#ticket_attachment_upload").fileupload
      # url: '/users/profile/temp_save_user_profile_image'
      # type: "POST"
      # maxFileSize: 1000000
      dataType: "json"
      # autoUpload: false
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png|doc|docx|pdf|ppt|pptx|xls|xlsx|csv)$/i
        # maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          data.context = $(tmpl('ticket_attachment_upload_tmpl', file))
          $(".ticket_attachment_wrapper").html(data.context)
          # data.submit()
          jqXHR = data.submit().complete( (result, textStatus, jqXHR)->
            # console.log result
            setTimeout (->
              $('#autoloadable_prepend').prepend Mustache.to_html($('#load_files').html(), result.responseJSON)
              $(".ticket_attachment_wrapper").empty()
              return
            ), 3000
          )
        else
          alert("#{file.name} is not a recommended file format")
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          data.context.find(".progress-bar").css("width", progress+"%").html(progress+"%")
          if progress==100
            console.log "ok"

  prevent_enter: ->
    $("#new_ticket").keypress (event) ->
      event.preventDefault()  if event.keyCode is 10 or event.keyCode is 13
      return

  check_submit: ->
    $("#ticket_attachment_upload").hide()
    $(".sample").keyup ->
      $(".sample").each ->
        if $("#ticket_description").val().length is 0 or $("input[name='ticket[initiated_through]']:checked").length is 0 or $("#ticket_subject").val().length is 0            # alert $(@).val()
          $("#ticket_attachment_upload").hide()
        else
          $("#ticket_attachment_upload").show()
        return
    $(".sample").click ->
      $(".sample").each ->
        if $("#ticket_description").val().length is 0 or $("input[name='ticket[initiated_through]']:checked").length is 0 or $("#ticket_subject").val().length is 0
          $("#ticket_attachment_upload").hide()
        else
          $("#ticket_attachment_upload").show()
        return