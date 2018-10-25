window.Contracts =
  setup: ->
    return

  disabled_datepicker: ->
    $("#ticket_contract_contract_end_at").prop('disabled', true);
    # $('#ticket_contract_contract_start_at').blur ->
    #   _this = this
    #   if $(this).val() != ''
    #     $("#ticket_contract_contract_end_at").prop('disabled', false);
    #     $('#ticket_contract_contract_end_at').datepicker 'remove'
    #     $('#ticket_contract_contract_end_at').datepicker
    #       format: "dd-mm-yyyy"
    #       todayBtn: true
    #       todayHighlight: true
    #       startDate: $(_this).val()
    #   else
    #     $("#ticket_contract_contract_end_at").prop('disabled', true);
    return

  import_excel_upload: ->
    $("#import_excel_upload").fileupload
      url: '/contracts/bulk_product_upload'
      maxFileSize: 1000000
      dataType: "script"
      autoUpload: false
      formData:
        refer_resource_id: $("#data_carrier").data("referenceid")
        refer_resource_class: $("#data_carrier").data("referenceclass")
        timestore: $("#data_carrier").data("timestore")

      add: (e, data) ->
        types = /(\.|\/)(xlsx)$/i
        maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          if maxsize > file.size
            data.context = $(tmpl('import_csv_upload_output', file))
            $(".import_csv_wrapper").html(data.context)
            data.submit()
          else
            alert "Your image file is with #{file.size}KB is exceeding than limited size of #{maxsize}KB. Please select other image file not exceeding 1MB"
        else
          alert("#{file.name} is not a XLSX file format.")
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          data.context.find(".progress-bar").css("width", progress+"%").attr("aria-valuenow", "#{progress}").html(progress+"%")
          if progress==100
            $("#ajax-loader").addClass("hide")
            # $(".profile_image_wrapper").empty();