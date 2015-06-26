#2014_10_28
window.Users =
  setup: ->
    @user_profile_upload()
    return

  initiate_tooltip: ->
    $("a[rel~=tooltip], .has-tooltip").tooltip()


  user_profile_upload: ->
    $("#user_avatar").fileupload
      # url: '/users/profile/temp_save_user_profile_image'
      # type: "POST"
      maxFileSize: 1000000
      dataType: "script"
      autoUpload: false
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png)$/i
        maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          if maxsize > file.size
            data.context = $(tmpl('profile_image_upload', file))
            $(".profile_image_wrapper").html(data.context)
            data.submit()
          else
            alert "Your image file is with #{file.size}KB is exceeding than limited size of #{maxsize}KB. Please select other image file not exceeding 1MB"
        else
          alert("#{file.name} is not a gif, jpg, jpeg, or png image file")
        # alert data.files[0]
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          data.context.find(".progress-bar").css("width", progress+"%").html(progress+"%")
          if progress==100
            $("#ajax-loader").addClass("hide")
            # $(".profile_image_wrapper").empty();

  request_printer_application: (url, data, action, ticket_id, fsr_id, invoice_id)->
    _this = this
    parent_data = data
    $.post "/tickets/get_template", (data)->
      data = parent_data+data["print_template"]
      console.log data
      $.ajax
        async: false
        method: 'post'
        url: url
        data: data
        timeout: 4000
        success: (result)->
          response = result
          console.log response
      _this.update_database_after_printer_application(action, ticket_id, fsr_id, invoice_id)
      $("#ticket_print").text("Re-Print")

  update_database_after_printer_application: (action, ticket_id, fsr_id, invoice_id)->
    $.ajax
      method: "post"
      url: "/tickets/after_printer"
      data: {ticket_action: action, ticket_id: ticket_id, fsr_id: fsr_id, invoice_id: invoice_id}
