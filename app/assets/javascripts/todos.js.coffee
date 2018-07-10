window.Todos =
  setup: ->
    # @load_more()

  load_more: (e)->
    _this = $(e)
    if _this.parents(".panel").eq(0).find(".panel-body").is(".hide")
      $.get("/todos/todo_more", {process_id: _this.data("process-id"), input_variables: _this.data("input-variables")}, (data)->
        $(".todo_loaded_mustache").remove()
        $(".panel-body").addClass("hide")
        _this.parents(".panel").eq(0).find(".panel-body").removeClass("hide").html Mustache.to_html($('#load_for_todo_mustache').html(), data)
      ).fail( ->
        alert("System has some error. Please try again.")
      )
    else
      _this.parents(".panel").eq(0).find(".panel-body").addClass("hide")