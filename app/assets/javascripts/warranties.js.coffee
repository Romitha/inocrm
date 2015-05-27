window.Warranties =
  setup: ->
    return

  warranty_select: (function_param)->
    $(".simple_form").remove()
    $.get "/warranties", {function_param: function_param}

  warranty_create: (function_param)->
    $.get "/warranties/new", {function_param: function_param}

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

  tab_trigger: ->
    $('#qa').trigger 'click'
    $("#save_next").click()

  numbersonly: ->
    $('.press').keydown (e) ->
      unicode = if e.charCode then e.charCode else e.keyCode
      if unicode != 8
        #if the key isn't the backspace key (which we should allow)
        if unicode < 48 or unicode > 57
          return false
        #disable key press
      return