window.Tickets =
  setup: ->
    @load_customer()
    @pop_url_doc_upload()
    @prevent_enter()
    @description_more()
    @initial_loaders()
    @pass_to_re_correction()
    @pass_to_re_correction_trigger()
    @filter_sbu_engineer()
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

    return

  initial_loaders: ->
    $('.inline_edit').editable()

    $('.datepicker').datepicker
      format: "dd-mm-yyyy"
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
    $(".product_pop_doc_url").fileupload
      # url: '/users/profile/temp_save_user_profile_image'
      # type: "POST"
      maxFileSize: 1000000
      dataType: "script"
      autoUpload: false
      add: (e, data) ->
        console.log data

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

            console.log data.formData

            data.context = $(tmpl('pop_doc_url_upload', file))
            $(".pop_doc_url_wrapper", e.target ).html(data.context)
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
      $.post "/tickets/create_contact_persons", {data_param: $(@).data("param")}

  assign_contact_person: (id, contact_person, function_param)->
    $.post "/tickets/create_contact_persons", {contact_person_id: id, contact_person: contact_person, data_param: function_param}

  customer_select: (function_param, customer_id)->
    $.get "/tickets/new_customer", {function_param: function_param, customer_id: customer_id}

  assign_customer: (customer_id, organization_id, function_param)->
    # y = confirm("Are you sure?")
    # if y
    $.post "/tickets/create_customer", {customer_id: customer_id, organization_id: organization_id, function_param: function_param}

  load_datapicker: ->
    $('.datepicker').datepicker
      format: "dd M, yyyy"
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
    category_list = $("#product_product_category_id")
    category_list_html = category_list.html()
    category_list.empty()
    $("#product_product_brand_id").change ->
      selected = $("#product_product_brand_id :selected").text()
      filtered_option = $(category_list_html).filter("optgroup[label='#{selected}']").html()
      category_list.empty().html(filtered_option).trigger('chosen:updated')

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
      $.post "/tickets/call_resolution_template", {call_template: $(@).val(), task_id: $(":selected", @).data("task-id")}

  call_alert_template: (call_template)->
    _this = this
    $("#alert_template_caller").change ->
      _this.ajax_loader()
      $.post "/tickets/call_alert_template", {call_template: $(@).val()}

  call_mf_order_template: (call_template)->
    $("#mf_template_caller").change ->
      $.post "/tickets/call_mf_order_template", {call_template: $(@).val(), task_id: $(":selected", @).data("task-id")}

  toggle_hold_unhold: ->
    $("#hold_button").change ->
      $.post "/tickets/hold_unhold", {call_template: $(@).val()}

  call_extend_warranty_template: ->
    $("#extend_warranty_select").change ->
      $.post "/tickets/extend_warranty", {switch_to: $(":selected", @).val(), task_id: $(@).data("task-id")}

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
      $.post "/tickets/call_resolution_template", {call_template: "edit_fsr", select_fsr_id: $(@).val()}

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
    $("#fade").delay(2000).fadeOut(1000)

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

  load_serialparts: ->
    $("#load_serialparts").change ->
      brand_id = $(@).val()
      $.post("/tickets/load_serialparts", {brand_id: brand_id}, (data)->
        $('#load_serialparts_json_render').html Mustache.to_html($('#load_serialparts_output').html(), data)
      )

  select_brand_create_po: ->
    _this = this
    $("#brand1").change ->
      _this = this
      if $("#brand1").val()
        $("#hp_po_page").removeClass("hide")
      else
        $("#hp_po_page").addClass("hide")

      url = "/tickets/hp_po"

      this_data = {product_brand_id: $(@).val()}
      $.get url, this_data, (data)->
        $('#load_spareparts_json_render').html Mustache.to_html($('#load_spareparts_output').html(), data)
        # console.log $("#brand1").val()
        $("#so_po_currency_id").val($(":selected", _this).data("currencyid"))
        $("#so_po_product_brand_id").val($("#brand1").val())
        $("#dynamic_currency_code").text($(":selected", _this).data("currencycode"))
        # $('#create_hp_po_form').html ($('#create_ho_po_load').html(), data)
        # _this.initial_loaders()
        $("a[rel~=popover], .has-popover").popover()

  remove_spareparts: (elem)->

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
    $("#inventory_po_items").click() # add_link
    $("#inventory_po_items").prev().find(".single_extra_info").html($(_this).parent().prev().html()) # insert infor to remove
    $("#inventory_po_items").prev().find(".remove_nested_fields").data("insertedid", value)
    $("#inventory_po_items").prev().find(".spare_part_class").val(spare_part)
    $(".ticket_currency_class").val(ticket_currency_id)
    $("#inventory_po_items").prev().find(".po_description_class").val($(_this).parent().prev().find(".now_class").html())
    $("#inventory_po_items").prev().find(".item_no_class").val($(_this).parent().prev().find(".now_item_default").html())
    $("#inventory_po_items").prev().find(".po_amount_class").val($(_this).parent().prev().find(".now_amount_default").html())
    $("#inventory_po_items").prev().find(".remove").data("value", value)

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