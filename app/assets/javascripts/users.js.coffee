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
          data.context.find(".progress-bar").css("width", progress+"%").attr("aria-valuenow", "#{progress}").html(progress+"%")
          if progress==100
            $("#ajax-loader").addClass("hide")
            # $(".profile_image_wrapper").empty();

  request_printer_application: (print_object, print_object_id, request_type, tag_value, action)->
    _this = this
    $.post "/tickets/get_template", {print_object: print_object, print_object_id: print_object_id, request_type: request_type, tag_value: tag_value}, (data)->
      # headers:
      #   "Access-Control-Allow-Origin": "*"
      # headers:
      #   "Content-Type": "application/javascript; charset=utf-8"
      url = decodeURIComponent(data.url)
      console.log url
      $.ajax
        async: false
        method: 'post'
        url: url
        data: data["request_printer_template"]
        timeout: 4000
        success: (result)->
      _this.update_database_after_printer_application(action, print_object_id)
      $("#ticket_print").text("Re-Print")

  update_database_after_printer_application: (action, print_object_id)->
    $.ajax
      method: "post"
      url: "/tickets/after_printer"
      data: {ticket_action: action, print_object_id: print_object_id}

  update_create_fsr: ->
    _this = this
    $("#create_fsr_submit").click (e) ->
      e.preventDefault()
      $.post $("#create_fsr_form").attr("action"), $("#create_fsr_form").serialize(), (data) ->
        if data["print_fsr"]
          _this.request_printer_application('fsr', data['fsr_id'], 'fsr_request_type', 'print_fsr_tag_value', 'print_fsr')
          alert "FSR is being printed."
        else
          alert "FSR is created."
        window.location.href= "/tickets/#{data['ticket_id']}"

  search_customers: (elem)->
    modal_id = unless $(elem).data("modalid") is "undefined" then $(elem).data("modalid") else ""
    render_id = unless $(elem).data("renderid") is "undefined" then $(elem).data("renderid") else ""
    remote = unless $(elem).data("remote") is "undefined" then $(elem).data("remote") else ""
    select_path = unless $(elem).data("selectpath") is "undefined" then $(elem).data("selectpath") else ""
    select_options = unless $(elem).data("selectoptions") is "undefined" then $(elem).data("selectoptions") else ""

    $.get("/admins/searches/search_customers_suppliers?render_id=#{render_id}&modal_id=#{modal_id}&remote=#{remote}&select_path=#{select_path}&select_options=#{select_options}").fail(-> alert "Something went wrong in search engine. Please rectify with system administrator.")

  assign_customer: (elem, dom1, ref_dom)->
    _this = $(elem)
    $("##{dom1}").modal("hide");
    console.log $("##{ref_dom}").prev().attr("id")#find(".product_info:eq(0)").length
    $("##{ref_dom}").prev().find(".customer_supplier_info:eq(0)").html _this.data("content")

    $("##{ref_dom}").prev().find(".dynamic_customer_supplier_id:eq(0)").val(_this.data("customersupplierid"))