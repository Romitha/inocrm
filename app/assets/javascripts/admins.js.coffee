window.Admins =
  setup: ->
    @admin_menu_dropdown()
    @admin_ticket_reason()
    @filter_non_store_products()
    @product_validate()
    @filter_child()
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
    $("#inventory_product_id").empty()
    $("#inventory_store_id").change ->
      this_value = $(@).val()
      $.get "/admins/inventories/inventory?filter_products_by_store_id=#{this_value}", (data) ->
        options = data.options
        console.log options
        $("#inventory_product_id").html(options)

  product_validate: ->
    $("#validate_inventory_product").validate
      rules:
        "inventory_product[serial_no]":
          required: true,
          digits: true

  filter_child: ->
    parent_node = $(".parent_class")
    child_node = parent_node.parents().eq(2).find("."+parent_node.data("child-select-class"))
    child_html = child_node.html()
    child_node.empty()

    parent_node.change ->
      filtered_html = $(child_html).filter("optgroup[label = '#{$(@).val()}']").html()
      if filtered_html
        child_node.html(filtered_html)
      else
        child_node.empty()

  filter_product: (e)->
    this_value = $(e).val()
    $.get "/admins/inventories/filter_brand_product?#{$(e).data('filter-params')}=#{this_value}&render_dom=#{$(e).data('render-dom')}"

