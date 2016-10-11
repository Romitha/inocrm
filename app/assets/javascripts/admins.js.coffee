window.Admins =
  setup: ->
    @admin_menu_dropdown()
    @admin_ticket_reason()
    @filter_non_store_products()
    @product_validate()
    @filter_child()
    @import_csv_upload()
    @onClick_hide_quantity()
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
    parent_node.each ->
      parent_inherit_point = $(@).parents(".parent_inherit_point").eq(0)
      child_node = parent_inherit_point.next().find("."+$(@).data("child-select-class"))
      child_html = child_node.html()
      child_node.empty()

      $(@).change ->
        filtered_html = $(child_html).filter("optgroup[label = '#{$(@).val()}']").html()
        if filtered_html
          child_node.html(filtered_html)
        else
          child_node.empty()

  filter_product: (e)->
    this_value = $(e).val()
    $.get "/admins/inventories/filter_brand_product?#{$(e).data('filter-params')}=#{this_value}&render_dom=#{$(e).data('render-dom')}"


  import_csv_upload: ->
    $("#import_csv_upload").fileupload
      url: '/admins/inventories/upload_grn_file'
      maxFileSize: 1000000
      dataType: "script"
      autoUpload: false
      formData:
        refer_resource_id: $("#data_carrier").data("referenceid")
        refer_resource_class: $("#data_carrier").data("referenceclass")
        inventory_id: $("#data_carrier").data("inventoryid")
        inventory_product_id: $("#data_carrier").data("inventoryproductid")

      add: (e, data) ->
        types = /(\.|\/)(xlsx)$/i
        maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          if maxsize > file.size
            data.context = $(tmpl('import_csv_upload_output', file))
            $(".import_csv_wrapper").html(data.context)
            data.submit()
          else
            alert "Your image file is with #{file.size}KB is exceeding than limited size of #{maxsize}KB. Please select other image file not exceeding 1MB"
        else
          alert("#{file.name} is not a XLSX file format.")
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          data.context.find(".progress-bar").css("width", progress+"%").attr("aria-valuenow", "#{progress}").html(progress+"%")
          if progress==100
            $("#ajax-loader").addClass("hide")
            # $(".profile_image_wrapper").empty();

  onClick_hide_quantity: (elem) ->
    this_elem = $(elem)

    $(".dynamic_quantity").each ->
      _this = this
      $(_this).parents(".collapse").eq(0).on 'hidden.bs.collapse', ->
        $(_this).val("")
      return