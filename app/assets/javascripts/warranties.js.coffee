window.Warranties =
  setup: ->
    @numbersonly()
    return

  warranty_select: (function_param)->
    $(".simple_form").remove()
    $.get "/warranties", {function_param: function_param}

  warranty_create: (function_param, product_id)->
    $.get "/warranties/new", {function_param: function_param, product_id: product_id}

  warranty_assign: (warranty_id)->
    $.post "warranties/create", {warranty_id: warranty_id}

  update_datepicker: ->
    $('.selectpicker').change ->
      format_value = $(this).val()
      $('.datepicker').datepicker 'remove'
      $('.datepicker').datepicker
        format: format_value
        todayBtn: true
        todayHighlight: true
      return

  disabled_datepicker: ->
    $("#warranty_end_at").prop('disabled', true);
    $('#warranty_start_at').blur ->
      _this = this
      if $(this).val() != ''
        $("#warranty_end_at").prop('disabled', false);
        $('#warranty_end_at').datepicker 'remove'
        $('#warranty_end_at').datepicker
          format: $('.selectpicker').val() 
          todayBtn: true
          todayHighlight: true
          startDate: $(_this).val()
      else
        $("#warranty_end_at").prop('disabled', true);
    return

  control_datetime_fsr: ->
    $("#ticket_fsr_work_started_at").data("DateTimePicker").maxDate(new Date())
    $("#ticket_fsr_work_finished_at").prop("disabled", true)
    $("#ticket_fsr_work_started_at").blur ->
      _this = this
      if $(this).val() != ''
        $("#ticket_fsr_work_finished_at").prop('disabled', false)
        console.log $(this).val()
        $('#ticket_fsr_work_finished_at').data("DateTimePicker").maxDate(new Date()).minDate($(this).val())
      else
        $("#ticket_fsr_work_finished_at").prop('disabled', true).data("DateTimePicker").destroy();
    return


  update_end_at: (e)->
    this_value = $(e).val()
    end_at = $(e).parents().eq(2).siblings().find(".updateable_end_at")
    end_at.val("")
    end_at.datepicker 'remove'
    end_at.datepicker
      format: "yyyy-mm-dd"
      todayBtn: true
      todayHighlight: true
      startDate: this_value

  tab_trigger: ->
    $('#qa').trigger 'click'
    $("#save_next").click()

  numbersonly: ->
    $('.only_float').keydown (e) ->
      # if String.fromCharCode(e.keyCode).match(/[^0-9\.\b]/g)
      #   return false
      # $(@).regexMask(/^((1?[0-9])|([12][0-4]))(\.[05]?)?$/)
      $(@).regexMask('float-enus')
      return