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
    @generate_serial_no()
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
    $("#inventory_product_category3_id").change ->

      if $(@).val() != ""
        category_value = $(@).val()
        $("#serial_no_find").removeClass("hide")
        $("#find_serial_id").data("categoryid", category_value)
      else
        $("#serial_no_find").addClass("hide")
        $("#find_serial_id").data("categoryid", null)

      # console.log $("#find_serial_id").data("categoryid")

    $("#find_serial_id").click ->
      category_value = $(@).data("categoryid")
      $.get "/inventories/generate_serial_no?category3_id="+category_value, (response) ->
        $("#modal_for_main_part").modal()
        $("#modal_for_main_part .modal-body").html(Mustache.to_html($('#load_product_pic').html(), {"products": response}))

  generate_serial_no: ->
    generated_serial_no = parseInt($("#available_serial_no tbody > tr").data("serialno"))
    if !isNaN(generated_serial_no)
      generated_serial_no = generated_serial_no + 1
      str = "" + generated_serial_no
      pad = "00000"
      ans = pad.substring(0,pad.length - str.length) + str
      $("#inventory_product_serial_no").val(ans)
      $("#modal_for_main_part").modal("hide")
