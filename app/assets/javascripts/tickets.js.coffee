window.Tickets =
  setup: ->
    @load_customer()
    @ticket_attachment_upload()
    @prevent_enter()
    @description_more()
    return

  chosen_select: ->
    $('.chosen-select').chosen
      allow_single_deselect: true
      no_results_text: 'No results matched'
      width: '100%'

  load_customer: ->
    __this = this
    $(".find_customer").click ->
      find_customer = $(@).val()
      $.post("/tickets/find_customer", {find_by: find_customer}, (data)->
        switch find_customer
          when "customer"
            $('#load_for_customer_select_box').html Mustache.to_html($('#load_for_customer_select_box_mustache').html(), data)
            __this.ticket_customer_id_change()

          when "create_customer"
            $("#load_for_customer_select_box").empty()
            $("#customer_modal").modal()
            $('#load_for_model_box').html Mustache.to_html($('#load_for_create_user_for_mustache').html(), data)
            setTimeout ( ->
              __this.create_customer()
              return
            ), 300

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

  filter_agent: ->
    agents = $("#ticket_agent_ids").html()
    $("#ticket_agent_ids").empty()

    $("#ticket_department_id").change ->
      filtered_html = $(agents).filter("optgroup[label = '#{$(@).val()}']").html()
      if filtered_html
        $("#ticket_agent_ids").html(filtered_html)
      else
        $("#ticket_agent_ids").empty()

  description_more: ->
    showTotalChar = 200
    showChar = "Show (+)"
    hideChar = "Hide (-)"
    $(".desc").each ->
      content = $(this).text()
      if content.length > showTotalChar
        con = content.substr(0, showTotalChar)
        hcon = content.substr(showTotalChar, content.length - showTotalChar)
        txt = con + "<span class=\"dots\">...</span><span class=\"morectnt\"><span>" + hcon + "</span>&nbsp;&nbsp;<a href='#' class='showmoretxt'>" + showChar + "</a></span>"
        $(this).html txt
      return

    $(".showmoretxt").click ->
      if $(this).hasClass("sample")
        $(this).removeClass "sample"
        $(this).text showChar
      else
        $(this).addClass "sample"
        $(this).text hideChar
      $(this).parent().prev().toggle()
      $(this).prev().toggle()
      return

  remove_c_t_v_link: ->
    for n in [0, 1]
      do (n) ->
        $(".fields .remove_c_t_v_link:eq(0)").remove()

  search_sla: ->
    $(".search_sla").keyup ->
      search_sla_value = $(@).val()
      $.post "/tickets/select_sla", {search_sla: true, search_sla_value: search_sla_value}

  radio_for_sla: ->
    $(".radio_for_sla").click ->
      $.post "/tickets/"+$(@).data('param')

  select_sla: (id)->
    $("#product_brand_sla_id, #product_category_sla_id").val(id)
    $("#toggle_sla").modal("hide")