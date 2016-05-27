window.Admins =
  setup: ->
    @admin_menu_dropdown()
    @admin_ticket_reason()
    @filter_non_store_products()
    return

  admin_menu_dropdown: ->
    $(".with_submenu a.pull-right").click ->
      $("span",this).toggleClass("icon-chevron-left icon-chevron-down");

  admin_ticket_reason: ->
    $("#reason_hold").click ->
      if $(@).is(':checked')
        $("#fff").removeClass("hide")
      else
        $("#fff").addClass("hide")


  filter_non_store_products: ->
    # inventory_products = $("#inventory_product_id").html()
    $("#inventory_product_id").empty()
    $("#inventory_store_id").change ->
      this_value = $(@).val()
      $.get "/admins/inventories/inventory?filter_products_by_store_id=#{this_value}", (data) ->
        options = data.options
        console.log options
        $("#inventory_product_id").html(options)