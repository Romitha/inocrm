window.Inventories =
  setup: ->
    @filter_product()
    @filter_category()
    @filter_store()
    @calculate_cost_price()


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
    category_list = $("#search_inventory_mst_inv_product_category3_id")
    category_list_html = category_list.html()
    category_list.empty()
    $("#search_inventory_product").change ->
      selected = $("#search_inventory_product :selected").text()
      filtered_option = $(category_list_html).filter("optgroup[label='#{selected}']").html()
      category_list.html("<option></option>"+filtered_option).trigger('chosen:updated')


  disable_store: ->
    $("#ticket_spare_part_request_from_s").click ->
      if $("#ticket_spare_part_request_from_s").is(":checked")
        $(".part").removeClass("hide")
        $("#request_from_select").removeClass("hide")
        
      else
        $(".part").addClass("hide")
        $("#request_from_select").addClass("hide")

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
    part_of_main_product = $("#part_of_main_product, #ticket_on_loan_spare_part_part_of_main_product")
    if part_of_main_product.is(":checked")
      $("#part_of_main_product_select").removeClass("hide")
    else
      $("#part_of_main_product_select").addClass("hide")
      $("#mst_store_id").val("")
      $("#mst_inv_product_id, #ticket_on_loan_spare_part_main_inv_product_id").val("")
      $(".main_product").empty()

  disable_part: ->
    part_of_main_product = $("#part_of_main_product, #ticket_on_loan_spare_part_part_of_main_product")
    _this = this
    _this.disable_upon_check()

    part_of_main_product.click ->
      _this.disable_upon_check()

  submit_spare_part: ->
    submit_form = $("#new_ticket_spare_part")

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

      else if $("input[name='mst_store_id']", submit_form).val() and ( !$("input[name='store_id']", submit_form).val() or ($("input[name='store_id']", submit_form).val() != $("input[name='mst_store_id']", submit_form).val()))
        alert "Please select same store for the main product!"

      else
        submit_form.submit()

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

  calculate_approved_price: ->
    total_approved_amount = 0

    $(".approved_amount,.approved_estimate").each ->
      total_approved_amount = total_approved_amount + parseInt($(@).val())

    $("#total_approved_amount").html(total_approved_amount)

  accept_returned_part: (elem)->

    if $(elem).val() == "false"
      $(".reason").addClass("hide")
    else
      $(".reason").removeClass("hide")