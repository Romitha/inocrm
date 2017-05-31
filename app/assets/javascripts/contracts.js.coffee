window.Contracts =
  setup: ->
    return

  disabled_datepicker: ->
    $("#ticket_contract_contract_end_at").prop('disabled', true);
    $('#ticket_contract_contract_start_at').blur ->
      _this = this
      if $(this).val() != ''
        $("#ticket_contract_contract_end_at").prop('disabled', false);
        $('#ticket_contract_contract_end_at').datepicker 'remove'
        $('#ticket_contract_contract_end_at').datepicker
          format: "dd-mm-yyyy"
          todayBtn: true
          todayHighlight: true
          startDate: $(_this).val()
      else
        $("#ticket_contract_contract_end_at").prop('disabled', true);
    return

  # filter_select: (elem)->
  #   this_elem = $(elem)

  #   category_list = this_elem.prev().find(".product_product_category_class")
  #   brand_list = this_elem.prev().find(".product_product_brand_class")
  #   category_list_html = category_list.html()
  #   category_list.empty()

  #   console.log this_elem.prev()
  #   brand_list.change ->
  #     alert "hi"
  #     selected = $(":selected", brand_list).text()
  #     filtered_option = $(category_list_html).filter("optgroup[label='#{selected}']").html()
  #     category_list.empty().html(filtered_option).trigger('chosen:updated')