window.DocumentAttachment =
  setup: ->
    @document_attachment_upload()
    return

  document_attachment_upload: ->
    $("#document_attachment_file_path").fileupload
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
          data.context = $(tmpl('document_attachment_upload_tmpl', file))
          $(".document_attachment_wrapper").html(data.context)
          # data.submit()
          jqXHR = data.submit().complete( (result, textStatus, jqXHR)->
            # console.log result
            setTimeout (->
              $('#autoloadable_prepend').prepend Mustache.to_html($('#load_files').html(), result.responseJSON)
              $(".document_attachment_wrapper").empty()
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

  generated_document_upload: ->
    $(".generated_document_file_path").fileupload
      # url: '/users/profile/temp_save_user_profile_image'
      # type: "POST"
      # maxFileSize: 1000000
      dataType: "json"
      # autoUpload: false
      add: (e, data) ->
        console.log(data)
        updatedom = $(e.target).data("updatedom")
        contractdocumentid = $(e.target).data("contractdocumentid")
        types = /(\.|\/)(gif|jpe?g|png|doc|docx|pdf|ppt|pptx|xls|xlsx|csv)$/i
        # maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          data.formData = { contract_document_id: contractdocumentid }
          data.context = $(tmpl('document_attachment_upload_tmpl', file))
          $("#document_attachment_wrapper").html(data.context)
          data.submit().complete( (result, textStatus, jqXHR)->
            setTimeout (->
              $('#'+updatedom).html Mustache.to_html($('#load_files').html(), result.responseJSON)
              $("#document_attachment_wrapper").empty()
              return
            ), 3000
          )
        else
          alert("#{file.name} is not a recommended file format. Please upload .docx format document")
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          data.context.find(".progress-bar").css("width", progress+"%").html(progress+"%")
          if progress==100
            console.log "ok"