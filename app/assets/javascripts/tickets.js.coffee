window.Tickets =
  setup: ->
    @load_customer()
    @pop_url_doc_upload()
    @prevent_enter()
    @description_more()
    @initial_loaders()
    @pass_to_re_correction()
    @pass_to_re_correction_trigger()
    # @filter_sbu_engineer()
    @call_resolution_template()
    @call_alert_template()
    @call_mf_order_template()
    @validate_start_action()
    @action_taken_text()
    @hp_case_validation()
    @job_finished_validation()
    @select_fsr()
    @fade_flash_msg()
    @call_extend_warranty_template()
    @ticket_info_ajax_loader()
    @remote_true_loader()
    @toggle_hold_unhold()
    @update_without_return()
    @issue_store_parts_form_input_vanish()
    @seperate_product_row_colour()
    @part_of_main_product_row_colour()
    @pop_customer_info()
    @adjust_amount_check()
    @first_resolution_visible()
    @enable_request_part_check()
    @enable_update_only()
    @select_brand_create_po()
    @load_serialparts()
    @select_brand_create_invoice_for_so()
    @onsite_click()
    @numbersonly()
    @edit_fsr_travel_hours()
    @filter_category_report()
    @filter_category_ticket_report()
    @dynamically_filter_select_onload()
    @validate_po_no()
    return

  initial_loaders: ->
    $('.inline_edit').editable()

    $('.datepicker').datepicker
      format: "yyyy-mm-dd"
      todayBtn: true
      todayHighlight: true

    $('.datetimepicker').datetimepicker
      sideBySide: true

    $('.wysihtml5').each (i, elem)->
      $(elem).wysihtml5()

    $(".fancy_scroll_bar").mCustomScrollbar
      theme:"minimal-dark"

    $(".validate_form").validate()
    return

  bind_mCustomScrollbar: ->
    $(".fancy_scroll_bar").mCustomScrollbar
      theme: "rounded-dark"
      # themes are inset-2-dark, rounded-dots, rounded-dark

  autosave_form: (domId, storeKey)->
    console.log $('#'+domId).length
    # $('#'+domId).sisyphus
    #   customKeySuffix: storeKey
    #   onSave: ->
    #     console.log "Saved"
    #   onRestore: ->
    #     console.log "Restored"
    #   onRelease: ->
    #     console.log "released"
    $('#'+domId).phoenix('start')
    return

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

  save_cached_ticket: ->
    ticket_params = $("#new_ticket").serialize()
    $.post "/tickets/save_cache_ticket", ticket_params
    return

  pop_url_doc_upload: ->
    $("#product_pop_doc_url").fileupload
      # url: '/users/profile/temp_save_user_profile_image'
      # type: "POST"
      maxFileSize: 1000000
      dataType: "script"
      autoUpload: false
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png|pdf)$/i
        maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          if maxsize > file.size
            data.context = $(tmpl('pop_doc_url_upload', file))
            $(".pop_doc_url_wrapper").html(data.context)
            data.submit()
          else
            alert "Your image file is with #{file.size}KB is exceeding than limited size of #{maxsize}KB. Please select other image file not exceeding 1MB"
        else
          alert("#{file.name} is not a gif, jpg, jpeg, png  or pdf file")
        # alert data.files[0]
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          data.context.find(".progress-bar").css("width", progress+"%").html("<span class='sr-only'>"+progress+"% completed </span>")
          if progress==100
            $("#ajax-loader").addClass("hide");
            # $(".profile_image_wrapper").empty();

  multi_pop_url_doc_upload: ->
    _this = this
    $(".product_pop_doc_url").fileupload
      # url: '/users/profile/temp_save_user_profile_image'
      # type: "POST"
      maxFileSize: 1000000
      dataType: "script"
      autoUpload: false
      add: (e, data) ->
        _this.ajax_loader()

        output_class = $(e.target).data("class")
        types = /(\.|\/)(gif|jpe?g|png|pdf)$/i
        maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          if maxsize > file.size
            console.log "************"
            console.log data.form.serializeArray()
            # data.formData = {ajax_upload: true}
            formData = data.form.serializeArray()
            formData.push({name: "ajax_upload", value: true})

            data.formData = formData
            # data.formData.ajax_upload = true

            data.context = $(tmpl('pop_doc_url_upload', file))
            $("."+output_class ).html(data.context)
            data.submit()
          else
            alert "Your image file is with #{file.size}KB is exceeding than limited size of #{maxsize}KB. Please select other image file not exceeding 1MB"
            _this.remove_ajax_loader()
        else
          alert("#{file.name} is not a gif, jpg, jpeg, png  or pdf file")
          _this.remove_ajax_loader()
        # alert data.files[0]
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          data.context.find(".progress-bar").css("width", progress+"%").html("<span class='sr-only'>"+progress+"% completed </span>")
          if progress==100
            _this.remove_ajax_loader()

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

  pop_customer_info: ->
    $("#pop_customer_info").click ->
      $.post "/tickets/tickets_pack/informed_to_customer", {data_param: $(@).data("param")}

  adjust_amount_check: ->

    payment_received_sum = parseInt($("#payment_received_sum").text())
    payment_amount = parseInt($("#payment_amount").text())

    adjust_payment_amount_value = $(".adjust_payment_amount").val()

    final_amount_to_be_paid = payment_amount - payment_received_sum
    $("#final_amount_to_be_paid").text(final_amount_to_be_paid)

    $("#adjust_amount_check").click ->
      if $(@).is(":checked")

        $(".adjust").removeClass("hide")

        adjust_payment_amount_value = 0 if $(".adjust_payment_amount").val() == ""

        final_amount_to_be_paid1 = parseInt(adjust_payment_amount_value) - payment_received_sum
        $("#final_amount_to_be_paid").html(final_amount_to_be_paid1)

        $(".adjust_payment_amount").keyup ->
          adjust_payment_amount_value = parseInt($(@).val())
          adjust_payment_amount_value = 0 if isNaN(adjust_payment_amount_value)

          final_amount_to_be_paid1 = adjust_payment_amount_value - payment_received_sum
          $("#final_amount_to_be_paid").text(final_amount_to_be_paid1)

          $(".amount_before_adjust").val(payment_amount)
          $(".payment_amount").val(adjust_payment_amount_value)

      else
        $(".adjust").addClass("hide")
        $("#ticket_ticket_terminate_job_payment_amount, #ticket_ticket_terminate_job_payment_adjust_reason_id").val("")

        $("#final_amount_to_be_paid").html(final_amount_to_be_paid)

  select_sla: (id, content)->
    $("#product_brand_sla_id, #product_category_sla_id").val(id)
    $("#sla_content").html(content)
    $("#toggle_sla").modal("hide")

  select_contact_person: ->
    $("#contact_person1_select, #contact_person2_select, #report_person_select").click ->
      $(@).parent().siblings(".contact_persons_form").empty()
      $.post "/tickets/create_contact_persons", {data_param: $(@).data("param"), product_id: $(@).data("productid"), ticket_time_now: $(@).data('tickettimenow')}

  assign_contact_person: (id, contact_person, product_id, ticket_time_now, function_param)->
    $.post "/tickets/create_contact_persons", {contact_person_id: id, contact_person: contact_person, data_param: function_param, product_id: product_id, ticket_time_now: ticket_time_now}

  customer_select: (function_param, product_id, ticket_time_now, customer_id)->
    $.get "/tickets/new_customer", {function_param: function_param, customer_id: customer_id, product_id: product_id, ticket_time_now: ticket_time_now}

  assign_customer: (customer_id, product_id, ticket_time_now, organization_id, function_param)->
    $.post "/tickets/create_customer", {customer_id: customer_id, product_id: product_id, ticket_time_now: ticket_time_now, organization_id: organization_id, function_param: function_param}

  load_datapicker: ->
    $('.datepicker').datepicker
      format: "yyyy-mm-dd"
      todayBtn: true
      todayHighlight: true

  first_resolution_visible: ->
    if $(".first_resolution").is(':checked')
      $(".ticket_resolution_summary").removeClass("hide").prop("disabled", false)
    else
      $(".ticket_resolution_summary").addClass("hide").prop("disabled", true)

    $(".first_resolution").click ->
      if $(@).is(':checked')
        $(".ticket_resolution_summary").removeClass("hide").prop("disabled", false)
      else
        $(".ticket_resolution_summary").addClass("hide").prop("disabled", true)

  filter_select: ->
    category1_list = $("#search_product_category1")
    category1_list_html = category1_list.html()
    category1_list.empty()

    category2_list = $("#search_product_category2")
    category2_list_html = category2_list.html()
    category2_list.empty()

    category3_list = $("#product_product_category_id")
    category3_list_html = category3_list.html()
    category3_list.empty()

    $("#product_product_brand_id").change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
      category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category2_list.empty()
      category3_list.empty()

    $("#search_product_category1").change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
      category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category3_list.empty()

    $("#search_product_category2").change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
      category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')

  touch_refresh: ->
    $("#create_contact_person").trigger("click")

  product_update: ->
    $('.inline_edit').editable()

  disable_inline: ->
    $('.disable').editable("disable")

  activate_tabbable: ->
    $('#w_q_h_tab a').click (e) ->
      e.preventDefault()
      $(this).tab('show')
  popnote_more: ->
    $('.load_more').popover
      html: true

  remove_serial_search: ->
    $(".serial_search").remove()

  numbersonly: ->
    $('.only_float').keydown (e) ->
      # if String.fromCharCode(e.keyCode).match(/[^0-9\.\b]/g)
      #   return false
      # $(@).regexMask(/^((1?[0-9])|([12][0-4]))(\.[05]?)?$/)
      $(@).regexMask('float-enus')

    $('.after_two_decimal').keydown (e) ->
      # if String.fromCharCode(e.keyCode).match(/[^0-9\.\b]/g)
      #   return false
      # $(@).regexMask(/^((1?[0-9])|([12][0-4]))(\.[05]?)?$/)
      $(@).regexMask('after_two_decimal')

    $('.integer').keydown (e) ->
      # if String.fromCharCode(e.keyCode).match(/[^0-9\.\b]/g)
      #   return false
      # $(@).regexMask(/^((1?[0-9])|([12][0-4]))(\.[05]?)?$/)
      $(@).regexMask('integer')
    return

  pass_to_re_correction: ->
    if $("#ticket_regional_support_job").is(":checked")
      $(".regional_visible").removeClass("hide")
      $(".regional_visible select").prop("disabled", false)
      $(".regional_hiddible").addClass("hide")
      $(".regional_hiddible select").prop("disabled", true)

    else
      $(".regional_hiddible").removeClass("hide")
      $(".regional_hiddible, select").prop("disabled", false)
      $(".regional_visible").addClass("hide")
      $(".regional_visible select").prop("disabled", true)

    if $("#pass_to_re_correction").is(":checked")
      $(".pass_to_recorrection_hiddible").addClass("hide")
      $(".pass_to_recorrection_hiddible select, .pass_to_recorrection_hiddible input").prop("disabled", true)
    else
      $(".pass_to_recorrection_hiddible").removeClass("hide")
      $(".pass_to_recorrection_hiddible select, .pass_to_recorrection_hiddible input").prop("disabled", false)

  pass_to_re_correction_trigger: ->
    $("#pass_to_re_correction").click =>
      @pass_to_re_correction()

    $("#ticket_regional_support_job").click =>
      @pass_to_re_correction()

  filter_sbu_engineer: ->
    sbu_engineer = $("#assign_to").html()
    $("#assign_to").empty()
    sbu_engineer_for_regional = $("#assign_to_for_regional").html()
    $("#assign_to_for_regional").empty()

    $("#assign_sbu").change ->
      selected_text = $("#assign_sbu option:selected").text()
      filtered_html = $(sbu_engineer).filter("optgroup[label = '#{selected_text}']").html()
      if filtered_html
        $("#assign_to").html(filtered_html)
      else
        $("#assign_to").empty()

    $("#regional_support_center").change ->
      selected_text = $(@).val()
      filtered_html = $(sbu_engineer_for_regional).filter("optgroup[label = '#{selected_text}']").html()
      if filtered_html
        $("#assign_to_for_regional").html(filtered_html)
      else
        $("#assign_to_for_regional").empty()

  call_resolution_template: (call_template)->
    _this = this
    $("#template_caller").change ->
      _this.ajax_loader()
      $.post "/tickets/call_resolution_template", {call_template: $(@).val(), ticket_id: $(":selected", @).data("ticket-id"), task_id: $(":selected", @).data("task-id"), process_id: $(":selected", @).data("process-id"), engineer_id: $(":selected", @).data("engineer-id")}

  call_alert_template: (call_template)->
    _this = this
    $("#alert_template_caller").change ->
      _this.ajax_loader()
      $.post "/tickets/call_alert_template", {call_template: $(@).val()}

  call_mf_order_template: (call_template)->
    $("#mf_template_caller").change ->
      $.post "/tickets/call_mf_order_template", {call_template: $(@).val(), task_id: $(":selected", @).data("task-id"), ticket_id: $(":selected", @).data("ticket-id"), request_spare_part_id: $(":selected", @).data("request-spare-part-id")}

  toggle_hold_unhold: ->
    $("#hold_button").change ->
      $.post "/tickets/hold_unhold", {call_template: $(@).val()}

  call_extend_warranty_template: ->
    $("#extend_warranty_select").change ->
      $.post "/tickets/extend_warranty", {switch_to: $(":selected", @).val(), task_id: $(@).data("task-id"), ticket_id: $(@).data("ticket-id")}

  validate_start_action: ->
    $("#update_start_action").click (e)->
      e.preventDefault()
      if !($("#ticket_job_started_action_id").val() and $("#ticket_job_start_note").val())
        $("#error_msg").html("<div class='alert alert-danger'>Please complete required fields</div>")
        setTimeout (->
          $("#error_msg").empty()
          return
        ), 2000
      else
        $("#start_action_form").submit()

  action_taken_text: ->
    $("#action_taken_submit").click (e)->
      e.preventDefault()
      error = false
      if !$("#action_taken_text").val()
        error = true
      if $("#resolution_summary_text").length > 0 and !$("#resolution_summary_text").val()
        error = true
      if error
        $("#error_msg").html("<div class='alert alert-danger'>Please complete required fields</div>")
        setTimeout (->
          $("#error_msg").empty()
          return
        ), 2000
      else
        $("#action_taken_form").submit()

  hp_case_validation: ->
    $("#hp_case_submit").click (e)->
      e.preventDefault()
      if !$("#hp_case_text").val()
        $("#error_msg").html("<div class='alert alert-danger'>Please complete required fields</div>")
        setTimeout (->
          $("#error_msg").empty()
          return
        ), 2000
      else
        $("#hp_case_form").submit()

  job_finished_validation: ->
    $("#job_finish_submit").click (e)->
      e.preventDefault()
      if !($("#resolution_text").val() and $("#resolution_summary_text").val())
        $("#error_msg").html("<div class='alert alert-danger'>Please complete required fields</div>")
        setTimeout (->
          $("#error_msg").empty()
          return
        ), 2000
      else
        $("#job_finish_form").submit()

  select_fsr: ->
    $("#select_fsr").change ->
      $.post "/tickets/call_resolution_template", {call_template: "edit_fsr", select_fsr_id: $(":selected", @).val(), task_id: $(@).data("taskid"), ticket_id: $(@).data("ticketid")}

  suggestion_data: ->

    $.ajax
      dataType: "json"
      url: "/tickets/suggesstion_data.json"
      async: false
      success: (data)->

        states = new Bloodhound(
          datumTokenizer: Bloodhound.tokenizers.whitespace
          queryTokenizer: Bloodhound.tokenizers.whitespace
          local: data
        )
        $('#ticket_spare_part_spare_part_description.typeahead').typeahead {
          highlight: true
          limit: 10
        },
          name: 'state'
          source: states

  display_description_ticket_on_load_spare_part: ->
    $("#ticket_on_loan_spare_part_ref_spare_part_id").change ->
      ticket_spare_part_id = $(@).val()
      if ticket_spare_part_id
        $(".ticket_spare_part_#{ticket_spare_part_id}").removeClass("hide").siblings().addClass("hide")
      else
        $(".ticket_spare_part_description").each ->
          $(@).addClass("hide")

  fade_flash_msg: ->
    $("#fade").delay(2000).fadeOut(3000)

  check_validation: (tag_attrib, validation_method)->
    if validation_method == "presence"
      $(tag_attrib).val() != ""

    else if validation_method == "checked"
      $(tag_attrib).is(":checked")
    else
      true

  presence_validater: (elem, elems...)->
    _this = this
    active_elems = elems[0]
    $(".help-block").remove()
    submit = true
    for presence in active_elems.presence
      do (presence) ->
        validater = _this.check_validation(presence, "presence")

        if validater
          $(presence).parents(".form-group").removeClass("has-error")

        else
          $(presence).parents(".form-group").addClass("has-error")
          $(presence).after("<span class='help-block'>Can't be blank</span>")
          submit = false

    $(elem).parents("form").submit() if submit

  ajax_loader: ->
    $(".screener").addClass("fade")

  remove_ajax_loader: ->
    setTimeout (->
      $(".screener").removeClass("fade")
    ), 200

  ticket_info_ajax_loader: ->
    _this = this
    $(".ajax_loader").click ->
      __this = this
      _this.ajax_loader()
      $.get "/tickets/ajax_show", {partial_template_for_show: $(__this).data("partial-template-for-show"), ticket_id: $(__this).data("ticket-id"), edit_ticket: $(__this).data("edit-ticket")}
      # setTimeout (->
      #   return
      # ), 500

  remote_true_loader: ->
    _this = this
    $("[data-remote]").on( "ajax:success", (e, data, status, xhr) ->
      _this.ajax_loader()
    )
    # .on "ajax:error", (e, xhr, status, error) ->
    #   console.log error
    #   alert "Something wrong with server. Please try again or contact system administrator. Thank you."

  update_without_return: ->
    $("#update_without_return").click ->
      if $(@).is(":checked")
        $(@).siblings("[type='submit']").val("Save")
      else
        $(@).siblings("[type='submit']").val("Return")

  issue_store_parts_form_input_vanish: ->
    $("#issue_part_main_product [aria-controls]").on 'shown.bs.tab', (e) ->
      $(".tab-content #"+$(e.target).attr("aria-controls")).find("input, select").each ->
        $(@).prop("disabled", false)
      $(".tab-content #"+$(e.relatedTarget).attr("aria-controls")).find("input, select").each ->
        $(@).prop("disabled", true)

  seperate_product_row_colour: ->
    $('.seperate_product_ckeckbox').click ->
      $(".seperate_product_ckeckbox").parent().parent().removeClass("success")
      $(@).parent().parent().addClass("success")

  part_of_main_product_row_colour: ->
    $('.part_of_main_product_checkbox').click ->
      $(".part_of_main_product_checkbox").parent().parent().removeClass("success")
      $(@).parent().parent().addClass("success")

  update_complete: (e)->
    if $(e).is(":checked")
      $("#complete_update_submit").prop("disabled", false)
    else
      $("#complete_update_submit").prop("disabled", true)

  assign_value_to_select: ->
    $(".request_part_request_from .radio-inline input").click ->
      $("#request_from_select").attr("href", "/inventories/inventory_in_modal?select_frame=request_from&modified=true&checked_value="+$(@).val())

  enable_request_part_check: ->
    $(".approve_radio_button").change ->
      if $(@).val() == "true"
        $(".request_part_check").removeClass("hide").find("input").prop("disabled", false)
      else
        $(".request_part_check").addClass("hide").find("input").prop("disabled", true)

  check_previous: (e)->
    fa = $("#ticket_spare_part_faulty_serial_no").val()
    ct = $("#ticket_spare_part_faulty_ct_no").val()
    ticket_id = $(e).data("ticket-id")
    $.get "/tickets/ticket_in_modal?ct="+ct+"&fa="+fa+"&ticket_id="+ticket_id


  enable_update_only: ->
    $("#update_only_submit").prop("disabled", true).css("display", "none")
    $("#save_only_submit").css("display", "inline-block")

    $("#update_only").click ->
      if $(@).is(":checked")
        $("#update_only_submit").prop("disabled", false).css("display", "inline-block")
        $("#save_only_submit").css("display", "none")
      else
        $("#update_only_submit").prop("disabled", true).css("display", "none")
        $("#save_only_submit").css("display", "inline-block")

    $("#save_only_submit").click (e) ->
      net_amount = parseFloat($(@).data("deduction"))
      if $("#foc_payment_required").val() == "true" and net_amount > 0
        e.preventDefault()
        e.stopPropagation()
        alert "Net amount for final invoice #{net_amount} must be 0 for FOC. Please try again after reconciliation."
      else if $("input[name='payment_completed']").is(":checked")
        if not confirm("Do you really want to make payment complete?")
          e.preventDefault()
          e.stopPropagation()

  load_serialparts: ->
    $("#load_serialparts").change ->
      brand_id = $(@).val()
      $.post("/tickets/load_serialparts", {brand_id: brand_id}, (data)->
        $('#load_serialparts_json_render').html Mustache.to_html($('#load_serialparts_output').html(), data)
      )

  select_brand_create_po: ->
    _this = this
    $("#brand1").change ->
      __this = this
      if $("#brand1").val()
        $("#hp_po_page").removeClass("hide")
      else
        $("#hp_po_page").addClass("hide")

      url = "/tickets/hp_po"

      this_data = {product_brand_id: $(@).val()}
      $.get url, this_data, (data)->
        _this.ajax_loader()
        $('#load_spareparts_json_render').html Mustache.to_html($('#load_spareparts_output').html(), data)
        # console.log $("#brand1").val()
        $("#so_po_currency_id").val($(":selected", __this).data("currencyid"))
        $("#so_po_product_brand_id").val($("#brand1").val())
        $("#dynamic_currency_code").text($(":selected", __this).data("currencycode"))
        # $('#create_hp_po_form').html ($('#create_ho_po_load').html(), data)
        # _this.initial_loaders()
        $("a[rel~=popover], .has-popover").popover()
        _this.remove_ajax_loader()

  select_brand_create_invoice_for_so: ->
    $("#brand_id_for_sales").change ->
      product_brand_id = $(@).val()
      $.post "js_call_invoice_for_hp", {product_brand_id: product_brand_id}


  hp_po_remove: (elem)->
    _this = elem
    part_no = $(_this).data("value")

    this_id = $(_this).data("insertedid")
    $("#addclick_function_"+this_id).removeClass("hide")

    add_link = $("#add_#{part_no}")
    add_link.css("pointer-events", "auto")

  hp_po_add: (ticket_currency_id, spare_part, elem)->
    $("a[rel~=popover], .has-popover").popover("destroy")
    _this = elem
    value = $(_this).data("value")
    added_count = $("#sparepart_list").data("addedcount")
    $("#inventory_po_items").click() # add_link
    $("#inventory_po_items").prev().find(".single_extra_info").html($(_this).parent().prev().html()) # insert infor to remove
    $("#inventory_po_items").prev().find(".single_extra_info .now_item_default").html(added_count)
    $("#inventory_po_items").prev().find(".remove_nested_fields").data("insertedid", value)
    $("#inventory_po_items").prev().find(".spare_part_class").val(spare_part)
    $(".ticket_currency_class").val(ticket_currency_id)
    $("#inventory_po_items").prev().find(".po_description_class").val($(_this).parent().prev().find(".now_class").html())
    $("#inventory_po_items").prev().find(".item_no_class").val($(_this).parent().prev().find(".now_item_default").html())
    $("#inventory_po_items").prev().find(".po_amount_class").val($(_this).parent().prev().find(".now_amount_default").html())
    $("#inventory_po_items").prev().find(".remove").data("value", value)

    $("#sparepart_list").data("addedcount", (parseFloat(added_count)+1))

    $(_this).css("pointer-events", "none")
    $("a[rel~=popover], .has-popover").popover()


  view_so_po_items:(elem) ->
    po_id = elem
    $.post "js_call_invoice_item", {po_id: po_id}

  view_inv_so_po:(elem, inv_id) ->
    po_id = elem
    $.post "js_call_view_more_inv_so", {po_id: po_id, inv_id: inv_id}

  reset_so_po: ->
    $("#invoice_invoice_no").val("")
    $("#invoice_created_at").val("")
    $("#invoice_note").val("")

  onsite_click: ->
    activateOnSite = (elem)->
      if elem.val() is "2"
        $(".ticket_onsite_type").removeClass("hide")
        $(".ticket_onsite_type select").prop("disabled", false)
      else
        $(".ticket_onsite_type").addClass("hide")
        $(".ticket_onsite_type select").prop("disabled", true)

    ticket_type = $(".ticket_type")

    activateOnSite(ticket_type)

    ticket_type.click -> activateOnSite($(@))

  reset_searchpo:->
    $("#po_no_id").val("")
    $("#po_range_from_id").val("")
    $("#po_range_to_id").val("")
    $("#ticket_no_id").val("")

  disabled_end_at:->
    if $("#ticket_contract_contract_end_at").val() == ''
      $("#ticket_contract_contract_end_at").prop('disabled', true);

    $('#ticket_contract_contract_start_at').blur ->
      _this = this
      if $(this).val() != ''
        $("#ticket_contract_contract_end_at").prop('disabled', false);
      else
        $("#ticket_contract_contract_end_at").prop('disabled', true);
    return

  edit_fsr_travel_hours: (e)->
    elem = $(e)

    if $('#out_at').val() != ''
      $('#work_started').prop('disabled', false)
      $('#in_at').prop('disabled', false)

    if $('#work_started').val() != ''
      $('#work_finished').prop('disabled', false)


    date_finished = $("#work_finished").val()
    date_started = $("#work_started").val()

    date_in = $("#in_at").val()
    date_out = $("#out_at").val()

    finished = new Date(date_finished)
    started = new Date(date_started)

    in_at = new Date(date_in)
    out_at = new Date(date_out)

    worked_time = finished - started
    time_in_out = in_at - out_at

    if isNaN(worked_time)
      travel_time = time_in_out
    else
      travel_time = time_in_out - worked_time

    worked_time_in_hours = worked_time/(1000*60*60)
    travel_time_in_hours = travel_time/(1000*60*60)

    if $('#work_finished').val() != ''
      $('#worked_hours').val(worked_time_in_hours)
    if $('#in_at').val() != ''
      $('#travelled_hours').val(travel_time_in_hours)

  set_max_support_eng_worked_hours: (e)->
    elem = $(e)
    $(".support_worked_hours").val(0);
    $(".support_worked_hours").prop("max", $(elem).val());

  max_time_support: (e)->
    elem = $(e)
    sup_time = $(elem).val()
    eng_time = $("#worked_hours").val()
    if parseFloat($(elem).val()) > parseFloat($("#worked_hours").val())
      alert "Support engineer work hours can not be higher than engineer work hours"
      $(elem).val(eng_time)
  approveManufacturePart: (e)->
    console.log($(e))
    if $("input[name='ticket_spare_part[request_approved]']:checked").val() == "false"
      if confirm($(".alertMsg").data("msg"))
        $(e).parents("form").eq(0).submit();

    else
      $(e).parents("form").eq(0).submit();

  getEmailAddress:->
    $("#ticket_inform_cp").change ->
      selected_email = $(":selected", @).data("email")
      $("#email_to").val("to:#{selected_email}");

  emailSend:->
    if $("#send_email").is(":checked")
      $("#email_to").prop("disabled", false)

    else
      $("#email_to").val("");
      $("#email_to").prop("disabled", true)
  date_picker_call:->
    $('.datepicker').datepicker({
    format: "yyyy-mm-dd",
    todayBtn: true,
    todayHighlight: true
    });

  dynamically_filter_select_for_new:->
    category1_list = $("#search_product_category1_cus_product")
    category1_list_html = category1_list.html()
    category1_list.empty()

    category2_list = $("#search_product_category2_cus_product")
    category2_list_html = category2_list.html()
    category2_list.empty()

    category3_list = $("#organization_products_attributes_0_product_category_id")
    category3_list_html = category3_list.html()
    category3_list.empty()

    $("#organization_products_attributes_0_product_brand_id").change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
      category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category2_list.empty()
      category3_list.empty()

    $("#search_product_category1_cus_product").change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
      category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category3_list.empty()

    $("#search_product_category2_cus_product").change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
      category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')

  dynamically_filter_select: (el, position, parent_class='', cat1, cat2)->
    $('.datepicker').datepicker({
    format: "yyyy-mm-dd",
    todayBtn: true,
    todayHighlight: true
    });
    _this = $(el)
    if position == "prev"
      console.log 'say prev' 
      brand_id = _this.prev().find(".select_wrapper .product_brand")
      category1_id = _this.prev().find(".select_wrapper .product_category1")
      category2_id = _this.prev().find(".select_wrapper .product_category2")
      category3_id = _this.prev().find(".select_wrapper .product_category")

      category1_list = category1_id
      category1_list_html = category1_list.html()
      category1_list.empty()

      category2_list = category2_id
      category2_list_html = category2_list.html()
      category2_list.empty()

      category3_list = category3_id
      category3_list_html = category3_list.html()
      category3_list.empty()

      brand_id.change ->
        selected = $(":selected", @).val()
        console.log(selected)
        filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
        category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
        category2_list.empty()
        category3_list.empty()

      category1_id.change ->
        selected = $(":selected", @).val()
        console.log(selected)
        filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
        category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
        category3_list.empty()

      category2_id.change ->
        selected = $(":selected", @).val()
        console.log(selected)
        filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
        category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')

    else if position == "parent"
      console.log 'say parent'
      brand_id = _this.parents("."+parent_class).eq(0).find(".select_wrapper .product_brand")
      category1_id = _this.parents("."+parent_class).eq(0).find(".select_wrapper .product_category1")
      category2_id = _this.parents("."+parent_class).eq(0).find(".select_wrapper .product_category2")
      category3_id = _this.parents("."+parent_class).eq(0).find(".select_wrapper .product_category")
      console.log category1_id

      category1_list = category1_id
      category1_list_html = category1_list.html()

      category1_id.prop("disabled", true)
      category1_list.html("<option>#{cat1}</option>").trigger('chosen:updated')


      category2_list = category2_id
      category2_list_html = category2_list.html()

      category2_id.prop("disabled", true)
      category2_list.html("<option>#{cat2}</option>").trigger('chosen:updated')

      category3_list = category3_id
      category3_list_html = category3_list.html()

      category3_id.prop("disabled", true)

      brand_id.change ->
        console.log 'triggered'
        category1_id.prop("disabled", false)
        category2_id.prop("disabled", false)
        category3_id.prop("disabled", false)
        selected = $(":selected", @).val()
        console.log(category1_list_html)
        filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
        category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
        category2_list.empty()
        category3_list.empty()

      category1_id.change ->
        selected = $(":selected", @).val()
        console.log(selected)
        filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
        category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
        category3_list.empty()

      category2_id.change ->
        selected = $(":selected", @).val()
        console.log(selected)
        filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
        category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')

  dynamically_filter_select_onload: ->
    brand_id = $("#product_form_template").find(".select_wrapper .product_brand")
    category1_id = $("#product_form_template").find(".select_wrapper .product_category1")
    category2_id = $("#product_form_template").find(".select_wrapper .product_category2")
    category3_id = $("#product_form_template").find(".select_wrapper .product_category")

    category1_list = category1_id
    category1_list_html = category1_list.html()

    category1_id.prop("disabled", true)
    category1_list.html("<option></option>")


    category2_list = category2_id
    category2_list_html = category2_list.html()

    category2_id.prop("disabled", true)
    category2_list.html("<option></option>")

    category3_list = category3_id
    category3_list_html = category3_list.html()

    category3_id.prop("disabled", true)
    category3_list.html("<option></option>")

    brand_id.change ->
      category1_id.prop("disabled", false)
      category2_id.prop("disabled", false)
      category3_id.prop("disabled", false)
      selected = $(":selected", @).val()
      filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
      category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category2_list.empty()
      category3_list.empty()

    category1_id.change ->
      selected = $(":selected", @).val()
      filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
      category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category3_list.empty()

    category2_id.change ->
      selected = $(":selected", @).val()
      filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
      category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
  product_name: (el)->
    _this = $(el)
    brand_id = _this.parents(".product_cat").eq(0).find(".select_wrapper .product_brand")
    category1_id = _this.parents(".product_cat").eq(0).find(".select_wrapper .product_category1")
    category2_id = _this.parents(".product_cat").eq(0).find(".select_wrapper .product_category2")
    category3_id = _this.parents(".product_cat").eq(0).find(".select_wrapper .product_category")
    product_name = $(":selected", brand_id).text() + " "+$(":selected", category1_id).text() + "|"+ $(":selected", category2_id).text() + "|"+$(":selected", category3_id).text()
    name_id = _this.parents(".product_cat").eq(0).siblings(".pro_name").find(".product_name")
    name_id.val(product_name)
  product_name_for_ticket:->
    brand_id = $("#product_product_brand_id")
    category1_id = $("#search_product_category1")
    category2_id = $("#search_product_category2")
    category3_id = $("#product_product_category_id")
    product_name = $(":selected", brand_id).text() + " "+$(":selected", category1_id).text() + "|"+ $(":selected", category2_id).text() + "|"+$(":selected", category3_id).text()
    name_id = $("#product_name")
    name_id.val(product_name)

  filter_select_new_product: ->
    category1_list = $("#search_product_category1")
    category1_list_html = category1_list.html()
    category1_list.prop("disabled", true)

    category2_list = $("#search_product_category2")
    category2_list_html = category2_list.html()
    category2_list.prop("disabled", true)

    category3_list = $("#ticket_contract_product_category_id")
    category3_list_html = category3_list.html()
    category3_list.prop("disabled", true)

    $("#ticket_contract_product_brand_id").change ->
      category1_list.prop("disabled", false)
      category2_list.prop("disabled", false)
      category3_list.prop("disabled", false)

      selected = $("#ticket_contract_product_brand_id :selected").val()
      filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
      category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category2_list.empty().html("<option></option>")
      category3_list.empty().html("<option></option>")

    $("#search_product_category1").change ->
      category2_list.prop("disabled", false)
      selected = $("#search_product_category1 :selected").val()
      filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
      category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category3_list.empty()

    $("#search_product_category2").change ->
      category3_list.prop("disabled", false)
      selected = $("#search_product_category2 :selected").val()
      filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
      category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')

  filter_category_report: ->

    brand_id = $("#search_contracts_brand_name")
    category1_id = $("#search_product_category1")
    category2_id = $("#search_product_category2")
    category3_id = $("#search_contracts_category_cat_id")

    category1_list = category1_id
    category1_list_html = category1_list.html()
    category1_list.empty()

    category2_list = category2_id
    category2_list_html = category2_list.html()
    category2_list.empty()

    category3_list = category3_id
    category3_list_html = category3_list.html()
    category3_list.empty()

    brand_id.change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
      category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category2_list.empty()
      category3_list.empty()

    category1_id.change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
      category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category3_list.empty()

    category2_id.change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
      category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
  
  filter_category_ticket_report: ->
    brand_id = $("#search_contracts_ticket_contract_brand_name")
    category1_id = $("#search_product_category1_cost_analyse")
    category2_id = $("#search_product_category2_cost_analyse")
    category3_id = $("#search_contracts_ticket_contract_category_name")

    category1_list = category1_id
    category1_list_html = category1_list.html()
    category1_list.empty()

    category2_list = category2_id
    category2_list_html = category2_list.html()
    category2_list.empty()

    category3_list = category3_id
    category3_list_html = category3_list.html()
    category3_list.empty()

    brand_id.change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category1_list_html).filter("optgroup[label='#{selected}']").html()
      category1_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category2_list.empty()
      category3_list.empty()

    category1_id.change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category2_list_html).filter("optgroup[label='#{selected}']").html()
      category2_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')
      category3_list.empty()

    category2_id.change ->
      selected = $(":selected", @).val()
      console.log(selected)
      filtered_option = $(category3_list_html).filter("optgroup[label='#{selected}']").html()
      category3_list.empty().html("<option></option>"+filtered_option).trigger('chosen:updated')

  filter_bill_address: ->
    address_bill_list = $("#ticket_contract_bill_address_id")
    address_bill_list_html = address_bill_list.html()
    address_bill_list.prop("disabled", true)
    $("#ticket_contract_organization_bill_id").change ->
      address_bill_list.prop("disabled", false)
      selected = $("#ticket_contract_organization_bill_id :selected").text()
      filtered_option = $(address_bill_list_html).filter("optgroup[label='#{selected}']").html()
      address_bill_list.empty().html(filtered_option).trigger('chosen:updated')

    address_company_list = $("#ticket_contract_contact_address_id")
    address_company_list_html = address_company_list.html()
    address_company_list.prop("disabled", true)
    $("#ticket_contract_organization_contact_id").change ->
      address_company_list.prop("disabled", false)
      selected = $("#ticket_contract_organization_contact_id :selected").text()
      filtered_option = $(address_company_list_html).filter("optgroup[label='#{selected}']").html()
      address_company_list.empty().html(filtered_option).trigger('chosen:updated')

  get_brand_id: ->
    main_brand_text = $("#ticket_contract_product_brand_id :selected").text()
    main_cat_text = $("#ticket_contract_product_category_id :selected").text()
    main_cat1_text = $("#search_product_category1 :selected").text()
    main_cat2_text = $("#search_product_category2 :selected").text()

    brand_id = $("#ticket_contract_product_brand_id").val()
    cat1_id = $("#search_product_category1").val()
    cat2_id = $("#search_product_category2").val()
    cat_id = $("#ticket_contract_product_category_id").val()

    $("#product_brand").val(brand_id)
    $("#product_category1").val(cat1_id)
    $("#product_category2").val(cat2_id)
    $("#product_category3").val(cat_id)
   
    $("#product_brand1").val(main_brand_text)
    $("#product_cat1").val(main_cat1_text)
    $("#product_cat2").val(main_cat2_text)
    $("#product_cat3").val(main_cat_text)
    #   $(".product_brand_main").removeClass("hide");
    #   $(".product_brand_show").addClass("hide");

    # else
    #   $(".product_brand_main").addClass("hide");
    #   $(".product_brand_show").removeClass("hide");
  show_date: ->

    strDate = $("#ticket_contract_contract_start_at").val()
    dateParts = strDate.split("-");

    date1 = new Date(dateParts[2], (dateParts[1])-1, dateParts[0]);
    # get_start_date = $("#ticket_contract_contract_start_at").val()
    # convert_start_date = get_start_date.replace("-", ",");
    # converted_start_date = convert_start_date.replace("-", ",");
    # alert converted_start_date

    date = new Date(date1);
    date.setDate(date.getDate() - 1);



    d = new Date(date)
    year = d.getFullYear()
    month = (d.getMonth()+1)
    day = (d.getDate())

    if day < 10
      modi_day = '0'+day
    else
      modi_day = day

    if month < 10
      modi_month = '0'+month
    else
      modi_month = month
    someFormattedDate = (year+1) + '-' + (modi_month) + '-' + (modi_day)
    # finaldate = new Date(someFormattedDate)
    $("#ticket_contract_contract_end_at").val(someFormattedDate)

  balance_count: ->
    amount_box = parseFloat($("#contract_payment_received_amount").val())
    balance = parseFloat($("#balance_to_pay").val())
    if (amount_box == balance)
      $("#contract_payment_received_amount").val(balance)
      $("#payment_completed").val("true")
      $(".completed").removeClass("hide")
      $(".not_completed").addClass("hide")
    if (amount_box > balance)
      $("#contract_payment_received_amount").val(balance)
      $("#payment_completed").val("true")
      $(".completed").removeClass("hide")
      $(".not_completed").addClass("hide")
    if (amount_box < balance)
      $("#payment_completed").val("false")
      $(".completed").addClass("hide")
      $(".not_completed").removeClass("hide")
  
  filter_instalments: ->
    Type = $("#ticket_contract_payment_type").val()
    Instalments = $("#contract_payment_received_payment_installment").val()
    if (Type == "Annually")
      if (Instalments > 1 || Instalments < 0)
        $("#contract_payment_received_payment_installment").val(1)
    if (Type == "Monthly")
      if (Instalments > 12 || Instalments < 0)
        $("#contract_payment_received_payment_installment").val(12)
    if (Type == "Quarterly")
      if (Instalments > 4 || Instalments < 0)
        $("#contract_payment_received_payment_installment").val(4)
    if (Type == "Binnually")
      if (Instalments > 2 || Instalments < 0)
        $("#contract_payment_received_payment_installment").val(2)
  count_down_remove_product: ->
    num_of_products = parseInt($("#product_count").val())
    remove_product = (num_of_products - 1)

    $("#product_count").val(remove_product)
    $("#product_count").click()

  brand_edit: ->
    num_of_products = parseInt($("#product_count").val())
    if num_of_products == 0
      $(".product_brand_main").removeClass("hide");
      $(".product_brand_show").addClass("hide");
    else
      $(".product_brand_main").addClass("hide");
      $(".product_brand_show").removeClass("hide");
  calculate_installments: ->
    end_dateParts = $("#ticket_contract_contract_end_at").val().split("-");
    end_date = new Date(end_dateParts[2], (end_dateParts[1]), end_dateParts[0]);

    start_dateParts = $("#ticket_contract_contract_start_at").val().split("-");
    start_date = new Date(start_dateParts[2], (start_dateParts[1]), start_dateParts[0]);
    Type = $(":selected","#ticket_contract_payment_type_id").text()
    if (Type == "Annually")
      num_of_ins = 12
    if (Type == "Monthly")
      num_of_ins = 1
    if (Type == "Quarterly")
      num_of_ins = 3
    if (Type == "Binnually")
      num_of_ins = 6

    months = (end_date.getFullYear()*12+end_date.getMonth())-(start_date.getFullYear()*12+start_date.getMonth())
    records = months/num_of_ins
    amo = 0
    dis_amo = 0
    sum_amo = 0
    sum_disamo = 0

    $("input.cus_product_amount1").each ->
      amo = $(this).val()
      sum_amo = parseFloat(sum_amo) + parseFloat(amo)

    $("a.cus_product_amount1").each ->
      amo = $(this).text()
      sum_amo = parseFloat(sum_amo) + parseFloat(amo)
    
    $("input.cus_product_disamount1").each ->
      dis_amo = $(this).val()
      sum_disamo = parseFloat(sum_disamo) + parseFloat(dis_amo)

    $("a.cus_product_disamount1").each ->
      dis_amo = $(this).text()
      sum_disamo = parseFloat(sum_disamo) + parseFloat(dis_amo)
    final_amount = (sum_amo - sum_disamo)
    amount_per_ins = (final_amount/Math.ceil(records))
    $.post("/contracts/load_installments", {start_date: start_date, end_date: end_date, installments: Math.ceil(records), num_of_ins:num_of_ins, amount_per_ins: amount_per_ins, final_amount: final_amount  }, (data)->
      $('#load_permissions_json_render').html Mustache.to_html($('#load_installments').html(), data)
    )

  expire_time_cal: ->
    start_dateParts = $("#date_from").val().split("-");
    start_date = new Date(start_dateParts[2], (start_dateParts[1]), start_dateParts[0]);
    Type = $(":selected","#time_period").val()
    if (Type == "1")
      num_of_mon = 30
    if (Type == "2")
      num_of_mon = 90
    requiredDate = new Date(start_date.getFullYear(),start_date.getMonth()-1,start_date.getDate()+num_of_mon)
    # alert Type
    # alert start_dateParts

    $("#date_to").val(requiredDate)

  decendent_cus: ->
    org = $(":selected","#organization_with_decendent").val()
    if org == ""
      $(".decendent").addClass("hide")
    else
      $(".decendent").removeClass("hide")

  activity_history_live_search: ->
    radio_button_checker = (e)->
      if $(e).is(":checked") and $(e).val() == "user"
        console.log "a"
        $(".user_radio_wrapper").removeClass("hide")
        $(".activity_radio_wrapper").addClass("hide")
      else if $(e).is(":checked") and $(e).val() == "activity"
        console.log "b"
        $(".user_radio_wrapper").addClass("hide")
        $(".activity_radio_wrapper").removeClass("hide")

    $(".activity_radio_class").click ->
      radio_button_checker(this)

    $(".activity_radio_class").each (e)->
      radio_button_checker(this)

    options =
      valueNames: [ 'action_description' ]
      listClass: "activity_history_live_search_list"
      searchClass: "search"

    activityHistoryList = new List("activity_history_list", options)

    $("#live_search_select_activity_history_activity").change ->
      console.log $(":selected", @).val()
      activityHistoryList.search($(":selected", @).val())

    userOptions =
      valueNames: [ 'user_name' ]
      listClass: "activity_history_live_search_list"
      searchClass: "search"

    activityHistoryListUser = new List("activity_history_list", userOptions)

    $("#live_search_select_activity_history_user").change ->
      console.log $(":selected", @).val()
      activityHistoryListUser.search($(":selected", @).val())

  validate_po_no: ->
    $("#so_po_po_no").blur ->
      _this = $(@)
      po_no = _this.val()
      $.post("/tickets/validate_po_no", {po_no: po_no}, (data)->
        $(".po_no_error").remove()
        _this.after("<label class='error po_no_error'>#{data.message}</label>")
      )
