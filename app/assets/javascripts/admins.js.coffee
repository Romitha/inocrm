window.Admins =
  setup: ->
    @admin_menu_dropdown()
    @admin_ticket_reason()
    @filter_non_store_products()
    @product_validate()
    @filter_child()
    @import_csv_upload()
    @onClick_hide_quantity()
    @currency_select()
    @grn_main_part_hover()
    @popup_button_enable()
    @serial_return_checkbox()
    @filter_permissions()
    @select_permission()
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
          required: true
          digits: true

          remote:
            # url: "/validate_resource?category3_id=#{$('input[name=inventory_product[category3_id] ]').val()}"
            url: "/validate_resource"
            type: "post"
            data:
              resource_name: "InventoryProduct"
              resource_column: "serial_no"
              more_attr:
                category3_id: ->
                  $("select[name='inventory_product[category3_id]']").val()

              resource_column_value: ->
                $( "input[name = 'inventory_product[serial_no]']" ).val()

      messages:
        "inventory_product[serial_no]":
          required: "Required input"
          digits: "Must be digits"
          remote: "Serial No is already used."

    # $('#inventory_product_generated_serial_no').on 'blur keyup', ->
    #   if $('#validate_inventory_product').valid()
    #     $('#submit_new_inventory_product').prop('disabled', false)
    #   else
    #     $('#submit_new_inventory_product').prop('disabled', true)

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
  
  filter_cat1: (e)->
    this_value = $(e).val()
    $.get "/admins/tickets/filter_brand_cat1?#{$(e).data('filter-params')}=#{this_value}&render_dom=#{$(e).data('render-dom')}"


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

  currency_select:  ->
    selected_currency_unit = $("#select_currency_unit")
    $(".dynamic_unit_cost").text($(":selected", selected_currency_unit).text())
    $(".dynamic_unit_id").val(selected_currency_unit.val())

    selected_currency_unit.change ->

      this_elem = $(@)

      $(".dynamic_unit_cost").text($(":selected",this_elem).text())
      $(".dynamic_unit_id").val(this_elem.val())

  grn_main_part_hover: ->
    $('[data-toggle="popover"]').popover()
    return


  inline_product_pic_upload: (elem)->
    this_elem = $(elem)
    tmpl = this_elem.data("tmpl")
    url = this_elem.data("url")
    attachwrapper = this_elem.data("attachwrapper")
    elem_result = this_elem.data("result")

    this_elem.fileupload
      url: url
      type: "PATCH"
      maxFileSize: 1000000
      dataType: "json"
      autoUpload: false
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png)$/i
        maxsize = 1024*1024
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          if maxsize > file.size
            data.context = $(tmpl(tmpl, file))
            $("."+attachwrapper).html(data.context)
            data.submit()
            jqXHR = data.submit().complete( (result, textStatus, jqXHR)->
              setTimeout (->
                $('#'+elem_result).html Mustache.to_html($('#load_product_pic').html(), result.responseJSON)
                $("."+attachwrapper).empty()
                return
              ), 3000
            )

          else
            alert "Your image file is with #{file.size}KB is exceeding than limited size of #{maxsize}KB. Please select other image file not exceeding 1MB"
        else
          alert("#{file.name} is not a recommended file format")
      progress: (e, data) ->
        $(".screener").addClass("fade")
        if data.context
          progress = parseInt(data.loaded/data.total*100, 10)
          # data.context.find(".progress-bar").css("width", progress+"%").html(progress+"%")
          data.context.find(".progress-bar").css("width", progress+"%").attr("aria-valuenow", "#{progress}").html(progress+"%")
          # if progress==100
          #   # window.location.reload()
          #   console.log "uploaded"
      done: (e, data) ->
        $(".screener").removeClass("fade")
        # console.log data#.responseJSON
        $('#'+elem_result).html Mustache.to_html($('#load_logo').html(), data)

      fail: (e, data) ->
        if data.textStatus == 401
          console.log data.textStatus

  popup_button_enable: ->
    $(".serial_class").change ->
      category1_id = category2_id = category3_id = ""

      if $(@).is("#search_inventory_brand") and $(@).val() is ""
        $("#serial_no_find").addClass("hide")
      else
        $("#serial_no_find").removeClass("hide")

      if $(@).is("#search_inventory_brand")
        category1_id = $(@).val()
        $("#find_serial_id").data "category1id", category1_id
      else if $(@).is("#search_inventory_product")
        category2_id = $(@).val()
        $("#find_serial_id").data "category2id", category2_id
      else if $(@).is("#inventory_product_category3_id")
        category3_id = $(@).val()
        $("#find_serial_id").data "category3id", category3_id

    $("#find_serial_id").click ->
      category1_value = $(@).data("category1id")
      category2_value = $(@).data("category2id")
      category3_value = $(@).data("category3id")

      $.get "/inventories/generate_serial_no?category[category3_id]="+category3_value+"&category[category2_id]="+category2_value+"&category[category1_id]="+category1_value

  generate_serial_no: ->
    #((((((((()))))))))
    generated_serial_no = parseInt($("#available_serial_no tbody > tr").data("serialno"))
    #((((((((()))))))))

    # #***************************************************************************
    # generated_serial_no = parseInt($("#available_serial_no tbody tr").last().data("serialno"))
    # #***************************************************************************

    # console.log generated_serial_no
    if !isNaN(generated_serial_no)
      generated_serial_no = generated_serial_no + 1
      str = "" + generated_serial_no
      pad = "000000"
      ans = pad.substring(0,pad.length - str.length) + str
      $("#inventory_product_serial_no").val(ans)
      $("#modal_for_main_part").modal("hide")

  select_serial_item_or_part_in_srn: (elem, item_type, item_id, randomId, item_product_id)->
    $.get "/admins/inventories/serial_item_or_part?item_type=#{item_type}&item_id=#{item_id}&item_product_id=#{item_product_id}", (response)->
      elem = $(elem)

      if randomId is "true"
        $("[id^='main_part_']").remove()
        random_id = (Math.floor(Math.random() * (100 - 1 + 1)) + 1)
        elem.prev().attr("id", random_id)
        elem.after("<div id='main_part_#{random_id}'></div>")

        window.localStorage.setItem("mainStoreIdPass", random_id)

      if item_type == "serial_item"
        $("#batch_or_serial_modal").modal({backdrop: "static"})
        render_id = "#srn_serial_item"
        $('#batch_or_serial_modal').html Mustache.to_html($(render_id).html(), response)

      else if item_type == "serial_part"
        render_id = "#srn_serial_part"
        $('#batch_or_serial_modal').html Mustache.to_html($(render_id).html(), response)

      else
        $("#batch_or_serial_modal").modal('hide')

        $("#"+window.localStorage.getItem("mainStoreIdPass")).val(item_id)

        serialPartInfo = elem.data("info")
        console.log serialPartInfo

        $("#main_part_"+window.localStorage.getItem("mainStoreIdPass")).html Mustache.to_html($("#selected_serial_part").html(), serialPartInfo)

        window.localStorage.clear("mainStoreIdPass")

  accumulated_qnty: (elem)->
    elem = $(elem)
    currentValue = parseFloat(elem.val())
    affecting_area_by_text = elem.parents(".accumulated_wrapper").eq(0).find(".accumulated_required_qty_text")
    affecting_area_by_val = elem.parents(".accumulated_wrapper").eq(0).find(".accumulated_required_qty_input")

    if elem.is("[type='text']")
      unless isNaN(currentValue)
        finalResult = affecting_area_by_val.data("preval") + currentValue - elem.data("preval")

      else
        finalResult = 0
        currentValue = 0

        elem.val(currentValue)


    else if elem.is("[type='checkbox']")
      if elem.is(":checked")
        currentValue = 1

        finalResult = affecting_area_by_val.data("preval") + currentValue

      else
        currentValue = 0

        finalResult = affecting_area_by_val.data("preval") - 1

      elem.parents(".individual_qnty").eq(0).find(".serial_return_qty").val(currentValue)

    console.log "final result is: #{finalResult} and current value is: #{currentValue}"

    if finalResult > parseFloat(affecting_area_by_val.data("maxqty"))
      console.log "maxed #{finalResult}"
      currentValue = elem.data("preval")
      finalResult = affecting_area_by_val.data("preval") + currentValue - elem.data("preval")
      elem.val(currentValue)

    affecting_area_by_text.text(finalResult)
    affecting_area_by_val.val(finalResult)
    elem.data("preval", currentValue)

    affecting_area_by_val.data("preval", finalResult)

  serial_return_checkbox: ->
    $(".serial_return_checkbox").each ->
      $(@).prop("checked", false)

  filter_permissions: ->
    permission_list = $("#class_id")
    permission_list_html = permission_list.html()
    permission_list.empty()

    permission_list = $("#permission_id")
    permission_list_html = permission_list.html()
    permission_list.empty()

    $("#role_id").change ->
      permission_list = $("#permission_id")
      permission_list_html = permission_list.html()
      permission_list.empty()

      type = $("#role_id").attr('type')
      value = $("#role_id").val()
      data = {value_key: value, type: type}

      $.post "/admins/roles/filter_permissions", data, (response) ->

        $("#class_id").html(response.option_html)

    $("#class_id").change ->
      type = $("#class_id").attr('type')
      value = $("#class_id").val()
      data = {value_key: value, type: type}

      $.post "/admins/roles/filter_permissions", data, (response) ->

        $("#permission_id").html(response.option_html)

  select_permission: ->
    $("#permission_id").change ->
      permission_id = $(@).val()
      $.post "subject_attributes_form", {permission_id: permission_id}