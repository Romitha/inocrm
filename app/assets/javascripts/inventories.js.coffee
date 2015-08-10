window.Inventories =
  setup: ->
    @filter_product()
    @filter_category()
    @filter_store()

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

  disable_manufacture: ->
    $("#ticket_spare_part_request_from_m").click ->
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