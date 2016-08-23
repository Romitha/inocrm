window.Searches =

  setup: ->
    @reset_searchgrn()
    return


  reset_searchgrn:->
    $("#store_id").val("")
    $("#grn_no").val("")
    $("#range_from").val("")
    $("#range_to").val("")