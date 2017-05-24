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