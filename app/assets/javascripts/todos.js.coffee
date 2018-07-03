window.Todos =
  setup: ->
    # @load_more()

  load_more: (e)->
    _this = $(e)
    $.get("/todos/todo_more", {process_id: _this.data("process-id"), ticket_id: _this.data("ticket-id"), estimation_id: _this.data("estimation-id"), ticket_spare_part_id: _this.data("ticket-spare-part-id"), onloan_spare_part_id: _this.data("onloan-spare-part-id")}, (data)->
      $(".todo_loaded_mustache").remove()
      $(".panel-body").addClass("hide")
      _this.parents(".panel").eq(0).find(".panel-body").removeClass("hide").html Mustache.to_html($('#load_for_todo_mustache').html(), data)
    ).fail( ->
      alert("System is too busy. Please try again.")
    )