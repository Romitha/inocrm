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

  disable_part: ->
    if $("#part_of_main_product").is(":checked")
      $("#part_of_main_product_select").removeClass("hide")
    $("#part_of_main_product").click ->
      if $("#part_of_main_product").is(":checked")
        $("#part_of_main_product_select").removeClass("hide")
      else
        $("#part_of_main_product_select").addClass("hide")
        $("#store_id").val("")
        $("#inv_product_id").val("")
        $(".main_product").empty()