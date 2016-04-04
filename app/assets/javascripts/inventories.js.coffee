window.Inventories =
  setup: ->
    @filter_product()
    @filter_category()
    @filter_store()
    @calculate_cost_price()
    @calculate_internal_cost_price()
    @terminate_func()
    @accept_returned_part()
    @accept_returned_part_func()
    @received_part_status()
    @check_return_serial_and_return_ct()
    @keypress_return_serial_and_return_ct()
    @bundle_load()
    @approve_store_part()
    @checked_quality_control()
    @checked_add_update_radio_for_bundle()
    @checked_add_update_radio_for_items()
    @checked_add_update_radio_for_parts()
    @disable_final_payment()
    @calculate_low_approved_price()
    @toggle_add_update_return_part()
    @damage_reason()
    @warranty_batch_check()
    @inventory_product_category()
    @customer_inquire_search()
    @hp_po_function()
    @add_append()
    @tax_calculation()
    # @remove_append()
    return

  tax_calculation: ->
    $("#estimated_tax_amount_id").click ->
      alert "gg"

  customer_inquire_search: ->
  add_append: ->
    $(".add_id2").click (e)->
      e.preventDefault()
      value= $(@).val()
      $("#remove_me_"+value).parents("tr").eq(0).removeClass("hide")
      $("#ticket_spare_part_"+value).prop("disabled", false)
      $(@).parents("tr").eq(0).addClass("hide")

    $(".remove_id2").click (e)->
      e.preventDefault()
      value= $(@).val()
      $("#add_me_"+value).parents("tr").eq(0).removeClass("hide")
      $("#ticket_spare_part_"+value).prop("disabled", true)
      $(@).parents("tr").eq(0).addClass("hide")

  hp_po_function: ->
    $("#search_inventory_brand").change ->
      selected = $(@).val()
      $("#idq2").html(selected)
  inventory_product_category: ->
    $("#inventory_product_category3_id").change ->
      selected = $(@).val()
      $("#ct").val(selected)
    $("#category2").change ->
      c2selected = $(@).val()
      $("#category1").val(c2selected)


  filter_product: ->
    category_list = $("#search_inventory_product")
    category_list_html = category_list.html()
    category_list.empty()
    $("#search_inventory_brand").change ->
      selected = $("#search_inventory_brand :selected").text()
      filtered_option = $(category_list_html).filter("optgroup[label='#{selected}']").html()
      category_list.html("<option></option>"+filtered_option).trigger('chosen:updated')

  filter_store: ->
    $("#search_inventory_store_id").change ->
      $("#search_inventory_product").val("")
      $("#search_inventory_brand").val("")
      $("#search_inventory_mst_inv_product_category3_id").val("")

  filter_category: -> 
    category_list = $("#search_inventory_mst_inv_product_category3_id, #inventory_product_category3_id")
    category_list_html = category_list.html()
    category_list.empty()
    $("#search_inventory_product").change ->
      selected = $("#search_inventory_product :selected").text()
      filtered_option = $(category_list_html).filter("optgroup[label='#{selected}']").html()
      category_list.html("<option></option>"+filtered_option).trigger('chosen:updated')

  disable_store: ->
    $("#ticket_spare_part_request_from_ns").click ->
      $(".request_from").empty()
      $("#store_id", "#mst_store_id", "#inv_product_id", "#mst_inv_product_id").val("")
      $(".not_non_stock").addClass("hide")

    $("#ticket_spare_part_request_from_s").click ->
      $(".request_from").empty()
      $("#store_id", "#mst_store_id", "#inv_product_id", "#mst_inv_product_id").val("")
      $(".not_non_stock").removeClass("hide")

      if $("#ticket_spare_part_request_from_s").is(":checked")
        $(".part").removeClass("hide")
        $("#request_from_select").removeClass("hide")

      else
        $(".part").addClass("hide")
        $("#request_from_select").addClass("hide")

  disable_final_payment: ->
    $("#ticket_ticket_terminate_job_foc_requested_true").click ->
      $(".payment_req").removeClass("hide")
    $("#ticket_ticket_terminate_job_foc_requested_false").click ->
      $(".payment_req").addClass("hide")


  checked_add_update_radio_for_bundle: ->
    $('.add_new_bundle').on 'change', ->
      $(".update_batch").addClass("hide")
      $(".add_batch").removeClass("hide")

    $('.update_bundle').on 'change', ->
      $(".update_batch").removeClass("hide")
      $(".add_batch").addClass("hide")

  checked_add_update_radio_for_items: ->
    $('.add_new_item').on 'change', ->
      $(".update_item_class").addClass("hide")
      $(".add_item").removeClass("hide")

    $('.update_item').on 'change', ->
      $(".update_item_class").removeClass("hide")
      $(".add_item").addClass("hide")

  checked_add_update_radio_for_parts: ->
    $('.add_new_part').on 'change', ->
      $(".update_part_class").addClass("hide")
      $(".add_part").removeClass("hide")

    $('.update_part').on 'change', ->
      $(".update_part_class").removeClass("hide")
      $(".add_part").addClass("hide")

  checked_quality_control: ->

    $("#act_quality_control_reject_reason").click ->
      if $(@).is(":checked")
        $("#dynamic_action_id").val($(@).data("approve-action-no"))
        $("#reject_reason_sec_hide").addClass("hide")
        $("#change_value_submit").val("Approve")
        $("#change_value_submit").attr("name", "approve")
        $("#reject_reason").prop("disabled", true)

      else
        $("#dynamic_action_id").val($(@).data("reject-action-no"))
        $("#reject_reason_sec_hide").removeClass("hide")
        $("#change_value_submit").val("Reject")
        $("#reject_reason").prop("disabled", false)
        $("#change_value_submit").attr("name", "reject")

  disable_upon_manufacture: ->
    if $("#ticket_spare_part_request_from_m").is(":checked")
      $("#request_from_select").addClass("hide")
      $(".request_from").empty()
      $(".main_product").empty()
      $("#store_id").val("")
      $("#mst_store_id").val("")
      $("#inv_product_id").val("")
      $("#mst_inv_product_id").val("")
      $(".part").addClass("hide")
      $("#part_of_main_product").attr('checked', false)
      $("#part_of_main_product_select").addClass("hide")
    else
      $("#request_from_select").removeClass("hide")
      $(".part").removeClass("hide")
      $("#part_of_main_product_select").removeClass("hide")

  disable_manufacture: ->
    _this = this
    $("#ticket_spare_part_request_from_m").click ->
      _this.disable_upon_manufacture()

  disable_upon_check: ->
    part_of_main_product = $("#part_of_main_product, #ticket_on_loan_spare_part_part_of_main_product, #order_man_rqst_frm_str_part_of_main_product")
    if part_of_main_product.is(":checked")
      $("#part_of_main_product_select").removeClass("hide")
    else
      $("#part_of_main_product_select").addClass("hide")
      $("#mst_store_id").val("")
      $("#mst_inv_product_id, #ticket_on_loan_spare_part_main_inv_product_id").val("")
      $(".main_product").empty()

  disable_part: ->
    part_of_main_product = $("#part_of_main_product, #ticket_on_loan_spare_part_part_of_main_product, #order_man_rqst_frm_str_part_of_main_product")
    _this = this
    _this.disable_upon_check()

    part_of_main_product.click ->
      _this.disable_upon_check()

  submit_spare_part: ->
    submit_form = $("#new_ticket_spare_part")
    _this = this

    $("input[type='submit']", submit_form).click (e)->
      e.preventDefault()
      spare_part_no = $("input[name='ticket_spare_part[spare_part_no]']", submit_form)
      spare_part_description = $("input[name='ticket_spare_part[spare_part_description]']", submit_form)
      request_from = $("input[name='ticket_spare_part[request_from]']:checked", submit_form)
      part_of_main_product = $("input[name='part_of_main_product']:checked", submit_form)


      if !spare_part_no.val() or !spare_part_description.val()
        alert "Please fill compulsory fields"

      else if request_from.val() == "S" and $("input[name='store_id']", submit_form).val() == ""
        alert "Please select store"

      else if part_of_main_product.val() and $("input[name='mst_store_id']", submit_form).val() == ""
        alert "Please select main product store"

      else if $("input[name='mst_store_id']").val() and ( !$("input[name='store_id']").val() or ($("input[name='store_id']").val() != $("input[name='mst_store_id']").val()))
        alert "Please select same store for the main product!"

      else
        submit_form.submit()

  request_from_store: ->
    if $("input[name='mst_store_id']").val() and ( !$("input[name='store_id']").val() or ($("input[name='store_id']").val() != $("input[name='mst_store_id']").val()))
      alert "Please select same store for the main product!"
    else
      false

  submit_on_loan_spare_part: ->
    @disable_part()
    submit_form = $("#new_ticket_on_loan_spare_part")

    $("input[type='submit']", submit_form).click (e)->
      e.preventDefault()
      spare_part_no = $("input[name='ticket_spare_part[spare_part_no]']", submit_form)
      spare_part_description = $("input[name='ticket_spare_part[spare_part_description]']", submit_form)
      request_from = $("input[name='ticket_spare_part[request_from]']:checked", submit_form)
      part_of_main_product = $("input[name='ticket_on_loan_spare_part[part_of_main_product]']:checked", submit_form)

      if $("input[name='ticket_on_loan_spare_part[store_id]']", submit_form).val() == ""
        alert "Please select store"

      else if part_of_main_product.val() and $("input[name='mst_store_id']", submit_form).val() == ""
        alert "Please select main product store"

      else if $("input[name='mst_store_id']", submit_form).val() and ( !$("input[name='ticket_on_loan_spare_part[store_id]']", submit_form).val() or ($("input[name='ticket_on_loan_spare_part[store_id]']", submit_form).val() != $("input[name='mst_store_id']", submit_form).val()))
        alert "Please select same store for the main product!"

      else
        submit_form.submit()

  calculate_cost_price: ->
    total_cost_price = 0
    total_estimated_price = 0
    total_margin_price = 0
    $(".est_external_cost_price, .est_add_cost_price").each ->
      total_cost_price = total_cost_price + parseInt($(@).val())
      $(@).parents().eq(2).find(".append_cost_price").html(parseInt($(@).val()))

    $(".est_external_estimated_price, .est_add_estimated_price").each ->
      total_estimated_price = total_estimated_price + parseInt($(@).val())
      $(@).parents().eq(2).find(".append_estimated_price").html(parseInt($(@).val()))
      cost_price = parseInt($(@).parents().eq(2).siblings().find(".append_cost_price").text())
      append_total = (parseInt($(@).val()) - cost_price)*100/cost_price

      ap_total = Math.round(append_total * 100)/100
      if ap_total < parseInt($("#db_margin").html())
        $(@).parents().eq(3).find(".append_profit_margin").css("color", "red")
      else
        $(@).parents().eq(3).find(".append_profit_margin").css("color", "black")

      if isNaN(ap_total)
        $(@).parents().eq(3).find(".append_profit_margin").html("")
      else
        $(@).parents().eq(3).find(".append_profit_margin").html(ap_total+"%")

    total_margin_price = (total_estimated_price - total_cost_price)*100/total_cost_price

    $("#total_estimated_price").html(total_estimated_price)
    $("#total_cost_price").html(total_cost_price)
    t_profit_price = Math.round(total_margin_price * 100)/100
    if t_profit_price < parseInt($("#db_margin").html())
      $("#total_margin_price").css("color", "red")
    else
      $("#total_margin_price").css("color", "black")

    if isNaN(t_profit_price)
      $("#total_margin_price").html("")
    else
      $("#total_margin_price").html(t_profit_price+"%")

  calculate_internal_cost_price: ->

    total_internal_cost_price = 0
    total_internal_estimated_price = 0
    total_internal_margin_price = 0

    $(".est_internal_cost_price, .est_internal_add_cost_price").each ->
      total_internal_cost_price = total_internal_cost_price + parseInt($(@).val())
      $(@).parents().eq(2).find(".append_cost_price_internal").html(parseInt($(@).val()))

    $(".est_internal_estimated_price, .est_internal_add_estimated_price").each ->
      total_internal_estimated_price = total_internal_estimated_price + parseInt($(@).val())
      $(@).parents().eq(2).find(".append_estimated_price_internal").html(parseInt($(@).val()))
      cost_price_internal = parseInt($(@).parents().eq(2).siblings().find(".append_cost_price_internal").text())
      append_total_internal = (parseInt($(@).val()) - cost_price_internal)*100/cost_price_internal

      ap_total_internal = Math.round(append_total_internal * 100)/100
      if ap_total_internal < parseInt($("#db_margin").html())
        $(@).parents().eq(3).find(".append_profit_margin_internal").css("color", "red")
        $(@).parents("fieldset").find(".below_margine_append_profit_margin_internal").html("Estimate below the margine").css("color", "red")
      else
        $(@).parents().eq(3).find(".append_profit_margin_internal").css("color", "black")
        $(@).parents("fieldset").find(".below_margine_append_profit_margin_internal").html("")

      if isNaN(ap_total_internal)
        $(@).parents().eq(3).find(".append_profit_margin_internal").html("")
      else
        $(@).parents().eq(3).find(".append_profit_margin_internal").html(ap_total_internal+"%")

    total_internal_margin_price = (total_internal_estimated_price - total_internal_cost_price)*100/total_internal_cost_price
    cal_total = Math.round(total_internal_margin_price * 100)/100
    $("#total_internal_estimated_price").html(total_internal_estimated_price)
    $("#total_internal_cost_price").html(total_internal_cost_price)

    if total_internal_margin_price < parseInt($("#db_margin").html())
      $("#total_internal_margin_price").html(cal_total).css("color", "red")
      $(".below_margine_total_internal_margin_price").html("Total Estimate below the margine").css("color", "red")
      $("[name='estimate_low_margin']").val("true")
    else
      $("#total_internal_margin_price").html(cal_total).css("color", "black")
      $(".below_margine_total_internal_margin_price").html("")
      $("[name='estimate_low_margin']").val("")

  calculate_approved_price: ->
    total_approved_amount = 0

    $(".approved_amount,.approved_estimate").each ->
      total_approved_amount = total_approved_amount + parseInt($(@).val())

    $("#total_approved_amount").html(total_approved_amount)

  accept_returned_part_func: ->
    _this = this
    $(".accept_returned_part").change ->
      _this.accept_returned_part()

  accept_returned_part: ->
    accept_returned_part_value = $(".accept_returned_part input:checked").val()
    if accept_returned_part_value == "true"
      $("#request_spare_parts").addClass("hide")
      $("#request_spare_parts select").prop("disabled", true).val("")
      $("#ticket_spare_part_manufacture").removeClass("hide")
      $("#ticket_spare_part_manufacture input.input_toggler").removeProp("disabled")
    else
      $("#request_spare_parts").removeClass("hide")
      $("#ticket_spare_part_manufacture").addClass("hide")
      $("#ticket_spare_part_manufacture input.input_toggler").prop("disabled", true).val("")
      $("#ticket_spare_part_manufacture input[type='checkbox']").removeProp("checked")
      $("#request_spare_parts select").removeProp("disabled")

  terminate_func: ->
    $(".part_terminated_reason_check").click ->

      if $(@).is(":checked")
        $(@).parents(".control-group").siblings(".part_terminated_reason").removeClass("hide")
        $(@).parents(".control-group").siblings(".store_request_wrapper").addClass("hide")

      else
        $(@).parents(".control-group").siblings(".part_terminated_reason").find(".part_terminated_select").val("")
        $(@).parents(".control-group").siblings(".part_terminated_reason").addClass("hide")
        $(@).parents(".control-group").siblings(".store_request_wrapper").removeClass("hide")

  received_part_status: ->
    _this = this
    $(".received_part_status").chosen().change ->
      return_part_serial_no_input = $(@).parents("form").find(".return_part_serial_no")

      return_part_ct_no_input = $(@).parents("form").find(".return_part_ct_no")

      $(@).parents("form").find(".unused_reason").prop("disabled", true).trigger("chosen:updated")


      if $(@).val() == "2" #used
        faulty_serial_no = $(@).parents(".panel-body").find(".faulty_serial_no").text()
        faulty_ct_no = $(@).parents(".panel-body").find(".faulty_ct_no").text()

        if not return_part_serial_no_input.is(".onloan")
          return_part_serial_no_input.prop("readonly", true)
          return_part_ct_no_input.prop("readonly", true)

        return_part_serial_no_input.val(faulty_serial_no)
        return_part_ct_no_input.val(faulty_ct_no)

      else if $(@).val() == "3" #un used
        $(@).parents("form").find(".unused_reason").prop("disabled", false).trigger("chosen:updated")
      else
        return_part_serial_no_input.prop("readonly", false)
        return_part_ct_no_input.prop("readonly", false)

      _this.check_return_serial_and_return_ct()

  check_return_serial_and_return_ct: ->
    $(".return_part_serial_no_text").each ->
      if $(@).parents("form").find(".received_part_status").val() == "2"
        $(@).text($(@).parents("form").find(".faulty_serial_no_input").val())
        $(@).parents("form").find(".return_part_serial_no").val($(@).parents("form").find(".faulty_serial_no_input").val())
      else
        $(@).text($(@).parents("form").find(".received_part_serial_no_input").val())
        $(@).parents("form").find(".return_part_serial_no").val($(@).parents("form").find(".received_part_serial_no_input").val())

    $(".return_part_ct_no_text").each ->
      if $(@).parents("form").find(".received_part_status").val() == "2"
        $(@).text($(@).parents("form").find(".faulty_ct_no_input").val())
        $(@).parents("form").find(".return_part_ct_no").val($(@).parents("form").find(".faulty_ct_no_input").val())
      else
        $(@).text($(@).parents("form").find(".received_part_ct_no_input").val())
        $(@).parents("form").find(".return_part_ct_no").val($(@).parents("form").find(".received_part_ct_no_input").val())
        

  keypress_return_serial_and_return_ct: ->
    _this = this
    $(".faulty_serial_no_input, .received_part_serial_no_input, .faulty_ct_no_input, .received_part_ct_no_input").each ->
      $(@).keyup ->
        _this.check_return_serial_and_return_ct()

  bundle_load: ->
    $("#brand_name").change ->

      #jQuery.get( url [, data ] [, success ] [, dataType ] )
      Tickets.ajax_loader()

      $.get $(@).data("url"), {product_brand_id: $(":selected", @).val(), template: $(@).data("template"), task_id: $(@).data("task-id")}, (data)-> Tickets.remove_ajax_loader()

  load_mustache_bundle_return_part: (action, manufacture_id)->
    Tickets.ajax_loader()
    if action == "remove_from_bundle"
      c = confirm "Are you sure! do you want to unbundle?"
      if c == true
        $.get "/tickets/bundle_return_part", {task_action: action, manufacture_id: manufacture_id}, (data)->
          if action == "remove_from_bundle"
            $('#bundle_return_part_from_undeliver_bundle').html Mustache.to_html($('#bundle_return_part_mustache').html(), data.bundle_manufactures)
            $('#bundle_return_part_add_mustache').html Mustache.to_html($('#bundle_return_part_mustache').html(), data.add_manufactures)
          
          Tickets.remove_ajax_loader()
          alert data.error_message if data.error_message
      else
        Tickets.remove_ajax_loader()
        

    else
      $.get "/tickets/bundle_return_part", {task_action: action, manufacture_id: manufacture_id}, (data)->
        if action == "add" or action == "remove"
          $(".title").removeClass("hide")
          $('#bundle_return_part_add_mustache').html Mustache.to_html($('#bundle_return_part_mustache').html(), data.add_manufactures)
          $('#bundle_return_part_remove_mustache').html Mustache.to_html($('#bundle_return_part_mustache').html(), data.remove_manufactures)

        else if action == "undelivered_bundle"
          $('#bundle_return_part_exist').html Mustache.to_html($('#bundle_return_part_exist_mustache').html(), data.bundles)
          $('#bundle_return_part_exist, #bundle_return_part_from_undeliver_bundle').removeClass("hide")
        else if action == "load_bundled_manufactures"
          $('#bundle_return_part_from_undeliver_bundle').html Mustache.to_html($('#bundle_return_part_mustache').html(), data.bundle_manufactures)
          $('#bundle_return_part_with_form').html Mustache.to_html($('#bundle_return_part_with_form_mustache').html(), data.bundle)

        else if action == "new_bundle"
          $('#bundle_return_part_with_form').html Mustache.to_html($('#bundle_return_part_with_form_mustache').html(), data.bundle, data.remove_manufactures)
          $('#bundle_return_part_exist, #bundle_return_part_from_undeliver_bundle').addClass("hide")
          
        Tickets.remove_ajax_loader()


  approve_store_part: ->

    if $(".approve_part_of_main_product:checked").val() is "true"
      $(".main_product_with_link").removeClass("hide")
    else
      $(".main_product_with_link").addClass("hide")

    if $(".request_approved:checked").val() is "true"
      $(".request_from_with_link").removeClass("hide")
      $(".main_product_with_link").removeClass("hide")
      $(".request_from_radio_buttons").removeClass("hide")

    else
      $(".request_from_with_link").addClass("hide")
      $(".main_product_with_link").addClass("hide")
      $(".request_from_radio_buttons").addClass("hide")
      $(".request_from_radio_buttons input[value='true']").prop("checked", true)

    $(".approve_part_of_main_product").change ->
      if $(@).val() is "true"
        $(".main_product_with_link").removeClass("hide")
      else
        $(".main_product_with_link").addClass("hide")

    $(".request_approved").change ->
      if $(@).val() is "true"
        $(".request_from_with_link").removeClass("hide")
        $(".main_product_with_link").removeClass("hide")
        $(".request_from_radio_buttons").removeClass("hide")

      else
        $(".request_from_with_link").addClass("hide")
        $(".main_product_with_link").addClass("hide")
        $(".request_from_radio_buttons").addClass("hide")
        $(".request_from_radio_buttons input[value='true']").prop("checked", true)

    $("#approve_store_part").click (e)->
      e.preventDefault()
      if $(".request_approved:checked").val() is "true" and $(".approve_part_of_main_product:checked").val() is "true"
        if $("#store_id").val() == $("#mst_store_id").val()
          $(@).parents("form").submit()
        else
          alert "Please select same stores"
      else
        $(@).parents("form").submit()


  load_serial_and_part: (elem, inventory_type_id, inventory_type, approved_part_product_id)->
    $.get "/inventories/load_serial_and_part?inventory_type_id="+inventory_type_id+"&inventory_type="+inventory_type+"&approved_part_product_id="+approved_part_product_id
    $(elem).parents("tr").siblings().css("background-color", "transparent")
    $(elem).parents("tr").eq(0).css({"background-color": "rgba(0,0,0,0.1)"})
    return

  calculate_low_approved_price: ->

    $(".low_margin_cost_price").each ->

      low_margin_estimate_rate = ( parseInt($(@).parents("fieldset").find(".low_margin_estimated_price").text()) - parseInt($(@).parents("fieldset").find(".low_margin_cost_price").text()) )*100/parseInt($(@).parents("fieldset").find(".low_margin_cost_price").text())
      if low_margin_estimate_rate < parseInt($("#db_margin").html())
        $(@).parents("fieldset").find(".low_margin_estimate_rate").html(Math.round(low_margin_estimate_rate * 100)/100).css("color", "red")
        $(@).parents("fieldset").find(".below_margine_low_margin_estimate_rate").html("Requested estimate below the margin").css("color", "red")
      else
        $(@).parents("fieldset").find(".low_margin_estimate_rate").html(Math.round(low_margin_estimate_rate * 100)/100).css("color", "black")
        $(@).parents("fieldset").find(".below_margine_low_margin_estimate_rate").html("")

      low_margin_approved_estimate_rate = ( parseInt($(@).parents("fieldset").find(".low_margin_approved_estimated_price").val()) - parseInt($(@).parents("fieldset").find(".low_margin_cost_price").text()) )*100/parseInt($(@).parents("fieldset").find(".low_margin_cost_price").text())
      if low_margin_approved_estimate_rate < parseInt($("#db_margin").html())
        $(@).parents("fieldset").find(".low_margin_approved_estimate_rate").html(Math.round(low_margin_approved_estimate_rate * 100)/100).css("color", "red")
        $(@).parents("fieldset").find(".below_margine_low_margin_approved_estimate_rate").html("Approved estimate below the margin").css("color", "red")
      else
        $(@).parents("fieldset").find(".low_margin_approved_estimate_rate").html(Math.round(low_margin_approved_estimate_rate * 100)/100).css("color", "black")
        $(@).parents("fieldset").find(".below_margine_low_margin_approved_estimate_rate").html("")

    low_margin_total_cost = 0
    low_margin_total_estimate = 0
    low_margin_total_app_estimate = 0

    $(".low_margin_cost_price, .add_low_margin_cost_price").each ->
      low_margin_total_cost = low_margin_total_cost + parseInt($(@).text())
    $(".total_low_margin_cost").html(low_margin_total_cost)

    $(".low_margin_estimated_price, .add_low_margin_estimated_price").each ->
      low_margin_total_estimate = low_margin_total_estimate + parseInt($(@).text())
    $(".total_low_margin_estimate").html(low_margin_total_estimate)

    $(".low_margin_approved_estimated_price, .add_low_margin_approved_estimated_price").each ->
      low_margin_total_app_estimate = low_margin_total_app_estimate + parseInt($(@).val())
    $(".total_low_margin_app_estimate").html(low_margin_total_app_estimate)

    total_estimate_profit = Math.round((low_margin_total_estimate - low_margin_total_cost)*100/low_margin_total_cost * 100)/100
    if total_estimate_profit < parseInt($("#db_margin").html())
      $(".total_estimate_profit").html(total_estimate_profit).css("color", "red")
      $(".margine_below_total_estimate_profit").html("Total requested estimate below the margin").css("color", "red")
    else
      $(".total_estimate_profit").html(total_estimate_profit).css("color", "black")
      $(".margine_below_total_estimate_profit").html("")

    total_approved_estimate_profit = Math.round((low_margin_total_app_estimate - low_margin_total_cost)*100/low_margin_total_cost * 100)/100
    if total_approved_estimate_profit < parseInt($("#db_margin").html())
      $(".total_approved_estimate_profit").html(total_approved_estimate_profit).css("color", "red")
      $(".margine_below_total_approved_estimate_profit").html("Total approved estimate below the margin").css("color", "red")
    else
      $(".total_approved_estimate_profit").html(total_approved_estimate_profit).css("color", "black")
      $(".margine_below_total_approved_estimate_profit").html("")

  toggle_add_update_return_part: ->
    $(".toggle_add_update").click ->
      $.get "/inventories/toggle_add_update_return_part?object_class="+$(@).data("object-class")+"&object_id="+$(@).data("object-id")+"&rew_record="+$(@).data("new-record")+"&reject="+$(@).data("reject")+"&uri="+$(@).data("uri-path")+"&task_id="+$(@).data("task-id")+"&owner="+$(@).data("owner")+"&process_id="+$(@).data("process-id")+"&currency_code="+$(@).data("currency-code")+"&active_spare_part="+$(@).data("active-spare-part")+"&currency_id="+$(@).data("currency-id")+"&grn_cost="+$(@).data("grn-cost")
      return

  submit_form: (form_attribute)->
    $(form_attribute).submit()

  damage_reason: ->
    damage_check = $(".damage_reason_check")
    damage_check_label = damage_check.siblings(".damage_reason_label")
    damage_select = damage_check.siblings(".damage_reason")

    damage_check.each ->
      if $(@).is(":checked")
        $(@).siblings(".damage_reason_label").removeClass("hide")
        $(@).siblings(".damage_reason").removeClass("hide")
        $(@).siblings(".damage_reason_label").removeClass("hide")
      else
        $(@).siblings(".damage_reason").addClass("hide")
        $(@).siblings(".damage_reason_label").addClass("hide")

      damage_check.click ->
        if $(@).is(":checked")
          $(@).siblings(".damage_reason_label").removeClass("hide")
          $(@).siblings(".damage_reason").removeClass("hide")
          $(@).siblings(".damage_reason_label").removeClass("hide")
        else
          $(@).siblings(".damage_reason").addClass("hide")
          $(@).siblings(".damage_reason_label").addClass("hide")

  warranty_batch_check: ->
    warranty_check = $(".warranty_check")
    grn_batch_check = $(".grn_batch_check")

    new_warranty = $(".new_warranty")
    new_grn_batch = $(".new_batch")

    warranty_check.click ->
      if warranty_check.is(":checked")
        new_warranty.removeClass("hide")
      else
        new_warranty.addClass("hide")
        new_warranty.find("input, select").each ->
          $(@).val("")

    grn_batch_check.click ->
      if grn_batch_check.is(":checked")
        new_grn_batch.removeClass("hide")
      else
        new_grn_batch.addClass("hide")
        new_grn_batch.find("input, select").each ->
          $(@).val("")