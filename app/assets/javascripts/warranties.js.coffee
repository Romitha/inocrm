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