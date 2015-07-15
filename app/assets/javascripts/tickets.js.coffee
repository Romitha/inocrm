window.Tickets =
  setup: ->
    @load_customer()
    @pop_url_doc_upload()
    @prevent_enter()
    @description_more()
    @initial_loaders()
    # @regional_support_job_active()
    @pass_to_re_correction()
    @pass_to_re_correction_trigger()
    @filter_sbu_engineer()
    @call_resolution_template()
    @validate_start_action()
    @action_taken_text()
    @hp_case_validation()
    @job_finished_validation()
    return

  initial_loaders: ->
    $('.inline_edit').editable()

    $('.datepicker').datepicker
      format: "dd M, yyyy"
      todayBtn: true
      todayHighlight: true

    $('.datetimepicker').datetimepicker
      sideBySide: true

    $('.wysihtml5').each (i, elem)->
      $(elem).wysihtml5()

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
    $(".ticket_resolution_summary").addClass("hide")
    $("#first_resolution").click ->
      if $(@).is(':checked')
        $(".ticket_resolution_summary").removeClass("hide")
      else
        $(".ticket_resolution_summary").addClass("hide")

  filter_select: ->
    category_list = $("#product_product_category_id")
    category_list_html = category_list.html()
    category_list.empty()
    $("#product_product_brand_id").change ->
      selected = $("#product_product_brand_id :selected").text()
      filtered_option = $(category_list_html).filter("optgroup[label='#{selected}']").html()
      category_list.empty().html(filtered_option).trigger('chosen:updated')

  regional_support_job_active: ->
    _this = this
    if !$("#ticket_ticket_type_id_2").is(":checked")
      $(".ticket_regional_support_job input[type='checkbox']").prop('checked', false)
      $(".ticket_regional_support_job").addClass("hide")
    $(".ticket_type").click ->
      if $(@).attr("id") == "ticket_ticket_type_id_2"
        $(".ticket_regional_support_job").removeClass("hide")
      else
        $(".ticket_regional_support_job").addClass("hide")
        $(".ticket_regional_support_job input[type='checkbox']").prop('checked', false)
      _this.pass_to_re_correction()


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
    $('.press').keydown (e) ->
      if String.fromCharCode(e.keyCode).match(/[^0-9\.\b]/g)
        return false
      return

  pass_to_re_correction: ->

    if $("#ticket_regional_support_job").is(":checked")
      $("#regional_support_center_chosen, #regional_support_center").parents().eq(1).removeClass("hide")
      $("#assign_sbu_chosen, #assign_sbu").parents().eq(1).addClass("hide")
      $("#assign_sbu_chosen, #assign_sbu").val("")
      $("#assign_to").val("")
      $("#assign_to_for_regional").removeClass("hide")
      $(".assign_to_for_regional_label").removeClass("hide")

    else
      $("#regional_support_center_chosen, #regional_support_center").parents().eq(1).addClass("hide")
      $("#regional_support_center_chosen, #regional_support_center").val("")
      $("#assign_sbu_chosen, #assign_sbu").parents().eq(1).removeClass("hide")
      $("#assign_to_for_regional").addClass("hide").val("")
      $(".assign_to_for_regional_label").addClass("hide")

    if $("#pass_to_re_correction").is(":checked")
      $(".pass_to_recorrection_hiddable").each ->
        $(@).addClass("hide")
        $("#assign_sbu_chosen, #assign_sbu").val("")
        $("#regional_support_center_chosen, #regional_support_center").val("")
        $("#assign_to").val("")
      $("#assign_to_for_regional").addClass("hide").val("")
      $(".assign_to_for_regional_label").addClass("hide")
    else
      $(".pass_to_recorrection_hiddable").each ->
        $(@).removeClass("hide")
      # $("#assign_to_for_regional").removeClass("hide")

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
    $("#template_caller option").click ->
      #alert $(@).val()
      $.post "/tickets/call_resolution_template", {call_template: $(@).val()}

  validate_start_action: ->
    # job_start_note = $("#ticket_job_start_note").val()
    # job_started_action = $("#ticket_job_started_action_id option:selected").val()
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
    # job_start_note = $("#ticket_job_start_note").val()
    # job_started_action = $("#ticket_job_started_action_id option:selected").val()
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