window.Admins =
  setup: ->
    @admin_menu_dropdown()
    return

  admin_menu_dropdown: ->
    $(".with_submenu a.pull-right").click ->
      $("span",this).toggleClass("icon-chevron-left icon-chevron-down");