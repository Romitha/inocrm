window.Reports =

  setup: ->
    @restrict_date_on_erp()
    return

  restrict_date_on_erp: ->
    change_dependency = (e)->
      source = e.currentTarget
      source_date = new Date($(source).val())
      start_date = new Date($(source).val())
      end_date = new Date()

      end_date.setMonth(source_date.getMonth() + 3 ) if (new Date(source_date.getFullYear(), (source_date.getMonth() + 3), source_date.getDay() )) < (new Date())

      $(".#{$(source).data('affectdataclass')}").prop("disabled", false).val("").datepicker('destroy').datepicker({
        startDate: start_date,
        endDate: end_date,
        format: "yyyy-mm-dd"
      })

    $(".date_restrict").datepicker({format: "yyyy-mm-dd", endDate: (new Date())}).on('changeDate', change_dependency)
    $(".date_restrict_log_affect").datepicker({format: "yyyy-mm-dd", endDate: (new Date())}).on('changeDate', change_dependency)
