jQuery ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()
  $('.inline_edit').editable()
  $('.datepicker').datepicker
    format: "dd M, yy"
    todayBtn: true
    todayHighlight: true

  $('.datetimepicker').datetimepicker
    sideBySide: true

  $('.wysihtml5').each (i, elem)->
    $(elem).wysihtml5()