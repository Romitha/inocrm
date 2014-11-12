#2014_10_28
window.Users =
  setup: ->
    @username_edit()
    @useremail_edit()
    @userpassword_edit()
    @useraddress_edit()
    return

  username_edit: ->
    $("#edit_name_link").mouseover ->
      $.ajax
        type: "GET"
        url: "/users/getusername/1"
        dataType: "json"
        success: (data, textStatus, xhr) ->
          content = {uname : data.user_name}
          Addresses.handlebar_template_render("#username_edit_modal_template", content, "#user_edit_popup_content")
          return
        error: ( xhr, textStatus, errorThrown ) ->
          $("#" + id + " .contentarea").html textStatus
          return

  useremail_edit: ->
    $("#edit_email_link").mouseover ->
      $.ajax
        type: "GET"
        url: "/users/getusername/1"
        dataType: "json"
        success: (data, textStatus, xhr) ->
          source = $("#useremail_edit_modal_template").html()
          template = Handlebars.compile(source)
          content =
            uemail : data.email
          html = template(content)
          $("#user_edit_popup_content").html html
          return
        error: ( xhr, textStatus, errorThrown ) ->
          $("#" + id + " .contentarea").html textStatus
          return 

  userpassword_edit: ->
    $("#edit_password_link").mouseover ->
      $.ajax
        type: "GET"
        url: "/users/getusername/1"
        dataType: "json"
        success: (data, textStatus, xhr) ->
          source = $("#userpw_edit_modal_template").html()
          template = Handlebars.compile(source)
          content =
            uemail : data.email
          html = template(content)
          $("#user_edit_popup_content").html html
          return
        error: ( xhr, textStatus, errorThrown ) ->
          $("#" + id + " .contentarea").html textStatus
          return

  useraddress_edit: ->
      $("#edit_address_link").mouseover ->
        $.ajax
          type: "GET"
          url: "/users/getusername/1"
          dataType: "json"
          success: (data, textStatus, xhr) ->
            source = $("#useraddress_edit_modal_template").html()
            template = Handlebars.compile(source)
            content =
              uemail : data.email
            html = template(content)
            $("#user_edit_popup_content").html html
            return
          error: ( xhr, textStatus, errorThrown ) ->
            $("#" + id + " .contentarea").html textStatus
            return

  initiate_tooltip: ->
    $("a[rel~=tooltip], .has-tooltip").tooltip()