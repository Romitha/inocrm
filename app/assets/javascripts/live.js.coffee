window.Lives =
  setup: ->
    @ticket_subscribe()

  ticket_subscribe: ->
    # $("#notification_window .alert").alert('close')

    dispatcher = new WebSocketRails('localhost:3000/websocket')

    dispatcher.bind 'tasks.create_success', (task)->
      $("#append_chat").append(task.content)
      console.log('successfully created ' + task.content)

    $("#send_chat").click (e)->
      e.preventDefault()
      task = { content: $("input[name='task[content]']").val() }
      dispatcher.trigger('tasks.create', task)

    channel = dispatcher.subscribe('posts')

    channel.bind 'new', (task)->
      $('#websocket_alert').popover('destroy')

      $("#notification_window").prepend("<div class='socket_list'>"+task.task_name+ " " +task.task_id+ " has "+task.task_verb+ " by "+task.by+ " "+task.at+"<hr></div>")

      content = $("#notification_window").html()

      $("#websocket_alert").popover
        content: content
        title: "Just arrived"
        placement: "bottom"
        html: true

      $('#websocket_alert').popover('show')