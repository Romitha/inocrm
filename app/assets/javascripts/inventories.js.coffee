window.Inventories =
  setup: ->
    @filter_product()
    @filter_category()
    @filter_store()
    # @calculate_cost_price()
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
    @hp_po_function()
    @add_append()
    @remove_warranty_click()
    @add_warranty_click()
    @need_serial_or_batch()
    @unit_calculation()

    return

  need_serial_or_batch: ->
    $(".need_serial_batch_check").change ->
      if $(@).is(":checked")
        $(".need_serial_batch_check").not(@).attr('checked', false)

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
    $("#search_inventory_brand").val("")
    $("#search_inventory_brand").change ->
      $("#inventory_product_category3_id").val("")
      selected = $("#search_inventory_brand :selected").val()
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
      selected = $("#search_inventory_product :selected").val()
      filtered_option = $(category_list_html).filter("optgroup[label='#{selected}']").html()
      category_list.html("<option></option>"+filtered_option).trigger('chosen:updated')

  disable_store: ->
    disable_loaded_requested_quantity = (elem)->
      $(".requested_quantity_manufacture_wrapper").addClass("hide")

      $(".requested_quantity_manufacture_wrapper input").prop
        disabled: true
        readonly: true

      $(".request_from").empty()
      $("#store_id", "#mst_store_id", "#inv_product_id", "#mst_inv_product_id").val("")
      $(".part").addClass("hide")
      $(".not_non_stock").removeClass("hide")
      $(".not_non_stock input").prop("disabled", false)
      $("#request_from_select").removeClass("hide")
      $(".main_product").empty()
      $("#part_of_main_product").attr('checked', false)

      switch elem.val()
        when "S"
          console.log "s"
          $(".not_non_stock").removeClass("hide")
          $(".part").removeClass("hide")
        when "M"
          $(".requested_quantity_manufacture_wrapper").removeClass("hide")
          $(".requested_quantity_manufacture_wrapper input").prop("disabled", false)

          $("#request_from_select").addClass("hide")
        when "NS"
          console.log "ns"
          $(".not_non_stock").addClass("hide")
          $(".not_non_stock input").prop("disabled", true)



    disable_loaded_requested_quantity($(".request_from_radio_buttons:checked"))

    $(".request_from_radio_buttons").click -> disable_loaded_requested_quantity($(@))

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
        $("#reject_reason").prop({"disabled": true, "required": false})

      else
        $("#dynamic_action_id").val($(@).data("reject-action-no"))
        $("#reject_reason_sec_hide").removeClass("hide")
        $("#change_value_submit").val("Reject")
        $("#reject_reason").prop({"disabled": false, "required": true})
        $("#change_value_submit").attr("name", "reject")

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

      else if request_from.val() == "NS" and $("input[name='store_id']", submit_form).val() == ""
        alert "Please select store"

      else if part_of_main_product.val() and $("input[name='mst_store_id']", submit_form).val() == ""
        alert "Please select main product store"

      else if $("input[name='mst_store_id']").val() and ( !$("input[name='store_id']").val() or ($("input[name='store_id']").val() != $("input[name='mst_store_id']").val()))
        alert "Please select same store for the main product!"
      else
        submit_form.submit()

  request_from_store: (e, elem)->
    if $("input[name='store_id']").val() == ""
      e.preventDefault()
      alert "Please select store product!"
      return false
    else if $("input[name='ticket_spare_part[ticket_spare_part_store_attributes][part_of_main_product]']").is(":checked") and $("input[name='mst_store_id']").val() == ""
      e.preventDefault()
      alert "Please select main product!"
      return false
    else if $("input[name='store_id']").val() != $("input[name='mst_store_id']").val() and $("input[name='mst_store_id']").val() != ""
      e.preventDefault()
      alert "Please select same store for the main product!"
      return false
    else
      alert "success"
      $(this).parents("form").eq(0).submit()

  submit_on_loan_spare_part: ->
    @disable_part()
    submit_form = $("#new_ticket_on_loan_spare_part")

    $("input[type='submit']", submit_form).click (e, elem)->
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

  unit_calculation: (e)->
    qty = parseFloat($("#qny_val").text())
    if isNaN(qty)
      qty = parseFloat(0)
    $("#unit_cost_price").text(parseFloat($("#cost_price_id").val())/qty)
    $("#unit_est_price").text(parseFloat($("#est_price_id").val())/qty)

    if $(e).is("#cost_price_id")
      $("#unit_cost_price").text(parseFloat($(e).val())/qty)
    if $(e).is("#est_price_id")
      $("#unit_est_price").text(parseFloat($(e).val())/qty)

  calculate_cost_price: (e)->
    elem = $(e)

    currentValue = parseFloat(elem.val())

    if !isNaN(currentValue)
      if elem.is(".estimation_value")
        @calculate_marginal_cost(elem, "estimation")
        @calculate_total_cost_estimated_price(elem, "estimation")

      else
        @calculate_marginal_cost(elem)
        @calculate_total_cost_estimated_price(elem)

      @calculate_total_amount()

  calculate_total_cost_estimated_price: (elem, cost_or_estimation)->
    pre = parseFloat(elem.data("initvalue"))
    current = parseFloat(elem.val())
    if cost_or_estimation is "estimation"
      total = parseFloat($("#total_estimated_price").text())
    else
      total = parseFloat($("#total_cost_price").text())

    if !isNaN(total) and !isNaN(pre) and !isNaN(current)
      newVal = total + current - pre

      if cost_or_estimation is "estimation"
        $("#total_estimated_price").text((Math.round(newVal * 100)/100).toFixed(2))
      else
        $("#total_cost_price").text((Math.round(newVal * 100)/100).toFixed(2))

      elem.data("initvalue", current)

  calculate_marginal_cost: (elem, cost_or_estimation)->
    relatives = elem.parents().eq(3).find(".append_profit_margin")
    cost = parseFloat(relatives.data("cost"))
    estimation = parseFloat(relatives.data("estimate"))
    margin = parseFloat($("#db_margin").text())
    currentValue = parseFloat(elem.val())

    if !isNaN(cost) and !isNaN(estimation) and !isNaN(currentValue)
      if cost_or_estimation is "estimation"
        profit = (currentValue-cost)*100/cost
        relatives.data("estimate", currentValue)
      else
        profit = (estimation-currentValue)*100/currentValue
        relatives.data("cost", currentValue)

      relatives.text((Math.round(profit * 100)/100).toFixed(2))

    if margin >= profit
      relatives.addClass("red")
    else
      relatives.removeClass("red")

  calculate_total_amount: ->
    total_estimation = parseFloat($("#total_estimated_price").text())
    total_tax = parseFloat($("#total_tax_price").text())
    total_cost = parseFloat($("#total_cost_price").text())
    margin = parseFloat($("#db_margin").text())

    $("#total_amount_with_tax").text((Math.round((total_estimation+total_tax) * 100)/100).toFixed(2)) if !isNaN(total_estimation) and !isNaN(total_tax)

    profit = (total_estimation - total_cost)*100/total_cost
    $("#total_margin_price").text((Math.round(profit * 100)/100).toFixed(2))

    if isNaN(margin) or margin >= profit
      $("#total_margin_price").addClass("red")
      $("#estimate_low_margin").val("true")
    else
      $("#total_margin_price").removeClass("red")
      $("#estimate_low_margin").val("")

  add_tax_value: (e)->
    _this = $(e)
    initValue = parseFloat(_this.data("initvalue"))
    currentValue = parseFloat(_this.val())
    targetValue = parseFloat($("#total_tax_price").text())

    if !isNaN(targetValue) and !isNaN(initValue) and !isNaN(currentValue)
      finalValue = targetValue - initValue + currentValue

      $("#total_tax_price").text((Math.round(finalValue * 100)/100).toFixed(2))
      _this.data("initvalue", currentValue)

      @calculate_total_amount()

  payment_amount_select: (e)->
    default_amount = parseFloat($(":checked", e).data("default-amount"))
    estimated_amount = parseFloat($(":checked", e).data("estimation-amount"))

    profit = parseFloat($("#db_margin").text())
    profit_margin = $(e).parent().siblings().find(".append_profit_margin")
    payment_item = $(e).parent().siblings().find(".payment_item_value")

    payment_item.val(default_amount).data("initvalue", 0)

    if profit_margin.length > 0
      profit_margin.data( {"cost": default_amount, "estimate": estimated_amount} )

      cost_price = payment_item
      elem = $(e).parent().siblings().find(".estimation_value")

      @calculate_cost_price cost_price

      elem.val(estimated_amount).data("initvalue", 0)

      @calculate_cost_price(elem)

    if $(e).is(".tax_rate_calculation")
      estimated_value = parseFloat($(e).parents(".estimate_extend_with_tax").eq(0).find(".estimation_value").data("initvalue"))

      if !isNaN(estimated_value) and !isNaN(default_amount)
        calculated_tax = default_amount * estimated_value/100
        $(e).parents(".parent_class_set").eq(0).find(".estimated_tax_amount_class").val(calculated_tax).data("initValue", 0)

        @add_tax_value($(e).parents(".parent_class_set").eq(0).find(".estimated_tax_amount_class")[0])

    @calculate_total_amount()
      # @add_tax_value($(e).parent().siblings().find(".estimated_value")[0])

  remove_tax_from_estimation: (e)->
    _this = $(e)
    removed_tax = parseFloat(_this.parents(".parent_class_set").eq(0).find(".estimated_tax_amount_class").val())
    total_tax = $("#total_tax_price").text()

    if !isNaN(removed_tax)
      total_tax -= removed_tax
      $("#total_tax_price").text(total_tax)
      @calculate_total_amount()

  remove_cost_estimation: (e)->
    this_e = $(e)
    r_estimation_price = parseFloat(this_e.parents(".estimate_extend_with_tax").eq(0).find(".append_profit_margin").data("estimate"))
    r_cost_price = parseFloat(this_e.parents(".estimate_extend_with_tax").eq(0).find(".append_profit_margin").data("cost"))

    total_cost_price = $("#total_cost_price").text()
    total_estimation_price = $("#total_estimated_price").text()

    total_cost_price -= r_cost_price
    total_estimation_price -= r_estimation_price

    $("#total_cost_price").text(total_cost_price)
    $("#total_estimated_price").text(total_estimation_price)

    taxes = 0
    this_e.parents(".estimate_extend_with_tax").eq(0).find(".estimated_tax_amount_class").each ->
      taxes += parseFloat($(this).val()) if !isNaN($(this).val())

    total_amount_with_tax = parseFloat($("#total_tax_price").text()) - taxes

    $("#total_tax_price").text((Math.round(total_amount_with_tax * 100)/100).toFixed(2))

    updated_margin = (total_estimation_price - total_cost_price)*100/total_cost_price
    $("#total_margin_price").text(Math.round(updated_margin * 100)/100)
    profit = parseFloat($("#db_margin").text())

    if profit >= updated_margin
      $("#total_margin_price").addClass("red")
      $("#estimate_low_margin").val("true")
    else
      $("#total_margin_price").removeClass("red")
      $("#estimate_low_margin").val("")

    @calculate_total_amount()


  approved_amount_calculation: (e)->
    total = parseFloat($("#total_approved_amount").text())
    next_val = parseFloat($(e).val())
    prev_val = parseFloat($(e).data("prev"))

    if !isNaN(total) and !isNaN(next_val) and !isNaN(prev_val)
      total = total + next_val - prev_val
      $("#total_approved_amount").text(total)
      $(e).data("prev", prev_val)

  limit_payment_required: (e)->
    value = parseFloat($(e).val())
    payment_limiter = parseFloat($(".for_payment_limit").text())
    if !isNaN(value) and !isNaN(payment_limiter)
      if value > payment_limiter
        $(e).val(payment_limiter)

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

  remove_warranty_click: (e)->
    setTimeout (->
      $(e).parent(".fields").siblings(".add_warranty").removeClass("hide")
    ), 200

  add_warranty_click: (e)->
    setTimeout (->
      # Tickets.load_datapicker()
      $('.datepicker').datepicker
        format: "yyyy-mm-dd"
        todayBtn: true
        todayHighlight: true

      if $(e).is(".add_warranty")
        $(e).addClass("hide")
    ), 200

  call_from_store: (elem) ->
    this_val = $(elem).val()
    $("#store_controller").removeClass("hide")
    $(".applyStoreId").data({"storeId": this_val, "storeid": this_val})
    $("#storeIdPassMainPart").data({"mainpartstoreid": this_val})

    $(".srn_store").addClass("hide")
    $("#store_name").text($(":selected", elem).text())

  assign_main_i_product_for_srn: (elem, result_out_dom)->
    store_id = $(elem).data("storeid")
    console.log store_id

  search_product_for_part: (elem)->
    console.log $(elem).data("modalid")
    store_id = unless $(elem).data("storeid") is "undefined" then $(elem).data("storeid") else ""
    modal_id = unless $(elem).data("modalid") is "undefined" then $(elem).data("modalid") else ""
    render_id = unless $(elem).data("renderid") is "undefined" then $(elem).data("renderid") else ""
    remote = unless $(elem).data("remote") is "undefined" then $(elem).data("remote") else ""
    select_path = unless $(elem).data("selectpath") is "undefined" then $(elem).data("selectpath") else ""
    select_options = unless $(elem).data("selectoptions") is "undefined" then $(elem).data("selectoptions") else ""

    $.get("/inventories/search_inventory_product?store_id=#{store_id}&render_id=#{render_id}&modal_id=#{modal_id}&remote=#{remote}&select_path=#{select_path}&select_options=#{select_options}")
    .done( ->
      setTimeout (->
        $('.datepicker').datepicker
          format: "yyyy-mm-dd"
          todayBtn: true
          todayHighlight: true

        if store_id isnt ""
          $(elem).prev().find(".select_main_part").remove()#.addClass("hide")

          if $(elem).is(".mainStoreIdPass")
            # used in SRN
            # Math.floor(Math.random() * (max - min + 1)) + min
            random_id = (Math.floor(Math.random() * (100 - 1 + 1)) + 1)
            $(elem).attr("id", random_id)
            window.localStorage.setItem("mainStoreIdPass", random_id)

        else if $(elem).is("#storeIdPassMainPart")
          $(elem).prev().find(".mainStoreIdPass").data({"storeId": $("#storeIdPassMainPart").data("mainpartstoreid"), "storeid": $("#storeIdPassMainPart").data("mainpartstoreid")})

        ), 100

      return
      
    ).fail(-> alert "Something went wrong in search engine. Please rectify with system administrator.")


  assign_product: (product_id, store_id, product_type)->
    applyable_dom = $("#new_srn .fields").last()
    applyable_dom.find("."+product_type).val(product_id)

    $.post("/inventories/product_info", {product_id: product_id, store_id: store_id}, (data)->
      applyable_dom.find("."+product_type+"_output").html Mustache.to_html($('#product_info_mustache').html(), data)
    ).done( (date)->
    ).fail( ->
      alert "There are some errors. please try again"
    )
    $("#search_product").modal("hide")

  assign_i_product: (elem, dom1, ref_dom)->
    _this = $(elem)
    $("##{dom1}").modal("hide");
    $("##{ref_dom}").prev().find(".product_info:eq(0)").html _this.data("content")
    $("##{ref_dom}").prev().find(".dynamic_main_product_id:eq(0)").val(_this.data("productid"))

    $("#"+window.localStorage.getItem("mainStoreIdPass")).prev().find(".product_info:eq(0)").html _this.data("content")
    $("#"+window.localStorage.getItem("mainStoreIdPass")).prev().find(".dynamic_main_product_id:eq(0)").val(_this.data("productid"))

    $(".applicable_product_id").val(_this.data("productid"))

  selected_quantity: (e)->
    selected_quantity = parseInt($("#selected_quantity").text())
    balance_quantity = parseInt($("#balance_to_be_issued").data("fixed"))
    if $(e).is(":checked")
      selected_quantity += 1
    else
      selected_quantity -= 1
    # $("#balance_to_be_issued").text(balance_quantity-selected_quantity)
    if (balance_quantity - selected_quantity) < 0
      alert "Selected quantity is exceeding balance quantity."
      $(e).prop("checked", false)
    else
      $("#selected_quantity").text(selected_quantity)


  apply_for_batch: ->
    balance_quantity_batch = parseFloat($("#balance_quantity_batch").data("fixed"))
    $(".batch_quantity").keyup ->
      selected_quantity_batch = 0
      this_elem = $(this)
      this_value = parseFloat(this_elem.val())
      remaining_quantity_batch = parseFloat(this_elem.parent().siblings().find(".remaining_quantity_batch").text())

      if !isNaN(this_value)

        if this_value > 0
          this_elem.next().find("input").prop("checked", true)
          if this_value > remaining_quantity_batch
            this_elem.val(remaining_quantity_batch)
        else
          this_elem.next().find("input").prop("checked", false)

        $(".batch_quantity").each ->
          if !isNaN($(this).val())
            selected_quantity_batch += parseFloat($(this).val())

        $("#selected_quantity_batch").text(selected_quantity_batch)
        # $("#balance_quantity_batch").text(balance_quantity_batch - selected_quantity_batch)
      else
        this_elem.val("0")
        $("#balance_quantity_batch").text(balance_quantity_batch - selected_quantity_batch)

  limit_visible_vat_web: (elem) ->
    this_elem = $(elem)

    if this_elem.val() == '1'
      $(".for_store_and_branch").removeClass("hide")
    else
      $(".for_store_and_branch").addClass("hide")
    return

  hide_last_purchase_prices: () ->
    $(".paginate_grn_select").click ->
      $('#paginate_grns').hide()
      return
    return