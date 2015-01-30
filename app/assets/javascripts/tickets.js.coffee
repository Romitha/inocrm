window.Tickets =
  setup: ->
    @load_customer()
    @ticket_attachment_upload()
    @prevent_enter()
    @check_submit()
    @ticket_customer_id_change()
    @filter_agent()
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

  check_submit: ->
    $("#ticket_attachment_upload").hide()
    $(".input_check").keyup ->
      $(".input_check").each ->
        if $("#ticket_description").val().length is 0 or $("input[name='ticket[initiated_through]']:checked").length is 0 or $("#ticket_subject").val().length is 0            # alert $(@).val()
          $("#ticket_attachment_upload").hide()
        else
          $("#ticket_attachment_upload").show()
        return
    $(".input_check").click ->
      $(".input_check").each ->
        if $("#ticket_description").val().length is 0 or $("input[name='ticket[initiated_through]']:checked").length is 0 or $("#ticket_subject").val().length is 0
          $("#ticket_attachment_upload").hide()
        else
          $("#ticket_attachment_upload").show()
        return

  create_customer: ->
    submit_button = $(".new_customer .btn-success")
    input_field = $(".new_customer .form-control")

    submit_button.prop "disabled", true
    input_field.keyup ->
      disabled = false
      input_field.each ->
        if $(@).val() == ""
          disabled = true
      submit_button.prop "disabled", disabled

    submit_button.click (e)->
      e.preventDefault()
      $.post "/tickets/create_customer", $(".new_customer").serialize(), (data, textStatus, jqXHR)->
        if data.errors
          $("#new_customer_errors").html "<div class = 'alert alert-danger new_customer_error'>#{data.errors}</div>"
        else
          $(".new_customer_error").remove()
          alert "New customer is successfully saved. You can continue add new customer"

  ticket_customer_id_change: ->
    $("#ticket_customer_id").change ->
      $(".more_about_user").remove()
      $(@).parent().append("<p class='more_about_user'><a href='#' onclick='Tickets.customer_summary_view(#{$(@).val()});'>Do you want to know more?</a></p>")

  customer_summary_view: (customer_id)->
    $.post "/tickets/customer_summary", {customer_id: customer_id}, (data, textStatus, jqXHR)->
      $("#customer_modal").modal()
      $('#load_for_model_box').html Mustache.to_html($('#load_customer_summary_mustache').html(), data)
      return

  load_new_comment: (comment_method, ticket_id)->
    _this = this
    $.post "/tickets/comment_methods",
      {comment_method: comment_method, ticket_id: ticket_id, to_email: $("#watcher").data("to-email"), customer: $("#reply").data("customer")},
      (data, textStatus, jqXHR)->
        $("#load_new_comment_for_ticket").html Mustache.to_html($("#load_new_comment_form_ticket_mustache").html(), data)
        $('.wysihtml5').each (i, elem)->
          $(elem).wysihtml5()
        _this.create_comment_for_ticket()
        return

  create_comment_for_ticket: ->
    $("#comment_create").click (e)->
      e.preventDefault()
      $.post( "/tickets/reply_ticket", $("#new_comment").serialize(), (data, textStatus, jqXHR)->
        $(".comment_list").prepend Mustache.to_html($("#comment_mustache").html(), data)
      ).fail( ->
        alert "Something went wrong. Please try again or contact system administrator"
      )

  filter_agent: ->
    agents = $("#ticket_agent_ids").html()
    $("#ticket_agent_ids").empty()

    $("#ticket_department_id").change ->
      filtered_html = $(agents).filter("optgroup[label = '#{$(@).val()}']").html()
      if filtered_html
        $("#ticket_agent_ids").html(filtered_html)
      else
        $("#ticket_agent_ids").empty()