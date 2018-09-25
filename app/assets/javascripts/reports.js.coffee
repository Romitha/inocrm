window.Reports =

  setup: ->
    @restrict_date_on_erp()
    @search_registered_customers()
    @suggestion_data()
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

  search_registered_customers: ->
    $("#search_registered_customers").change ->
      if $(":selected", this).val() != ""
        $("#check_children_wrapper").removeClass("hide")
      else
        $("#check_children_wrapper").addClass("hide")
        $("#check_children_wrapper input[type=checkbox]").prop(":checked", false)

  suggestion_data: ->

    states = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      prefetch:
        url: '/reports/customers.json'
        cache: true
    )
    $('#search_quotation_customer_name').typeahead {
      highlight: true
      limit: 10
    },
      name: 'state'
      source: states

