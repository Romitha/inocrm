window.Invoices =
  setup: ->
    @quotation_change()
    @check_fsr_dynamic_check_behavour()
    @customer_feedback_re_opened()
    @readonly_checkbox_in_customer_feedback()
    @activate_deducted_amount_terminate_foc()
    @on_click_adjust_check_visibility()
    @unit_returned_checkbox()
    @adjust_checked_visibility()
    return

  quotation_change: ->

    calculateTotal = (sub_amount, total_tax, min_adv_payment, total_payment, total_deduction)->
      final_total_amount = sub_amount - total_deduction
      amount_to_be_paid = final_total_amount - total_payment

      $("#sub_amount").text(parseFloat(sub_amount).toFixed(2))
      $("#sub_amount_value").val(sub_amount)

      $("#total_tax").text(parseFloat(total_tax).toFixed(2))
      $("#total_tax_value").val(total_tax)

      $("#min_adv_payment").text(parseFloat(min_adv_payment).toFixed(2))

      $("#total_payment").text(parseFloat(total_payment).toFixed(2))
      $("#total_payment_value").val(total_payment)

      $("#final_total_amount").text(parseFloat(final_total_amount).toFixed(2))

      $("#amount_to_be_paid").text(Math.round(amount_to_be_paid * 100)/100)
      $("#amount_to_be_paid_value").val(Math.round(amount_to_be_paid * 100)/100)

      $("#total_deduction").text(total_deduction)
      $("#total_deduction_value").val(total_deduction)

    calculateTax = (elem)->
      if elem.is(":checked")
        if isNaN(parseFloat(elem.parent().siblings(".tax").text())) then 0 else parseFloat(elem.parent().siblings(".tax").text())
      else
        0

    calculateSubAmount = (elem)->
      if elem.is(":checked")
        if isNaN(parseFloat(elem.parent().siblings(".sub_amount").text())) then 0 else parseFloat(elem.parent().siblings(".sub_amount").text())
      else
        0

    calculateMinAdvPayment = (elem)->
      if elem.is(":checked")
        if isNaN(parseFloat(elem.parent().siblings(".min_adv_payment").text())) then 0 else parseFloat(elem.parent().siblings(".min_adv_payment").text())
      else
        0

    calculateTotalPayment = ->
      totalPayment = 0
      $(".total_payment").each ->
        totalPayment += if isNaN(parseFloat($(@).text())) then 0 else parseFloat($(@).text())

      totalPayment

    deductedAmount = ->
      if !$("#deducted_amount").val() or isNaN(parseFloat($("#deducted_amount").val())) then 0 else parseFloat($("#deducted_amount").val())

    calculate = ->
      totalSubAmount = totalTax = MinAdvPayment = totalPayment = totalDeduction = 0

      $(".action").each ->
        totalSubAmount += calculateSubAmount($(@))
        totalTax += calculateTax($(@))
        MinAdvPayment += calculateMinAdvPayment($(@))

      totalDeduction = deductedAmount()

      totalPayment = calculateTotalPayment()

      calculateTotal(totalSubAmount, totalTax, MinAdvPayment, totalPayment, totalDeduction)

    calculate()
    $(".action").change -> calculate()
    $("#deducted_amount").keyup -> calculate()

  check_fsr_dynamic_check_behavour: ->

    $("#ticket_close_approved_check").click ->
      if $(@).is(":checked")
        $("#close_approve_reject_reason").addClass("hide").prop("disabled", true)
      else
        $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)

    not_all_checked = false
    $(".dynamic_check").each ->
      unless $(@).is(":checked")
        not_all_checked = true

    if not_all_checked
      $("#ticket_close_approved_check").prop
        checked: false
        disabled: true
      $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)
    else
      $("#ticket_close_approved_check").prop
        checked: true
        disabled: false
      $("#close_approve_reject_reason").addClass("hide").prop("disabled", true)

    $(".dynamic_check").click ->
      not_all_checked = false
      $(".dynamic_check").each ->
        unless $(@).is(":checked")
          not_all_checked = true

      if not_all_checked
        $("#ticket_close_approved_check").prop
          checked: false
          disabled: true
        $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)
      else
        $("#ticket_close_approved_check").prop
          checked: true
          disabled: false
        $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)

      if $("#ticket_close_approved_check").is(":checked")
        $("#close_approve_reject_reason").addClass("hide").prop("disabled", true)
      else
        $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)

    if $("#ticket_close_approved_check").is(":checked")
      $("#close_approve_reject_reason").addClass("hide").prop("disabled", true)
    else
      $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)

  customer_feedback_re_opened: ->
    $("#re_opened").change ->
      if $(@).is(":checked")
        $("#ticket_payment_reciever_wrapper").addClass("hide")
        $("#unit_return_customer").prop("disabled", true)
        $("#dispatch_method_id").prop("disabled", true)
        $("#unit_dispatch_wrapper").addClass("hide")
      else
        $("#ticket_payment_reciever_wrapper").removeClass("hide")
        $("#unit_dispatch_wrapper").removeClass("hide")
        $("#dispatch_method_id").prop("disabled", false)
        $("#unit_return_customer").prop("disabled", false)

  readonly_checkbox_in_customer_feedback: ->
    final_amount_to_be_paids = parseFloat($("#final_amount_to_be_paids").text())
    $("#ticket_payment_received_amount").keyup ->
      this_value = parseFloat($(@).val())
      if this_value == final_amount_to_be_paids
        $("#payment_completed").prop("checked", true).attr("onclick", "return false;")

      else if this_value > final_amount_to_be_paids
        $(@).val(final_amount_to_be_paids)
      else
        $("#payment_completed").removeAttr("onclick")

  activate_deducted_amount_terminate_foc: ->
    deducted_amount = $("#deducted_amount_text").val()
    if $("#approve_foc_check").is(":checked")
      $("#deducted_amount_text").prop("readonly", true)
      $("#deducted_amount_text").val(deducted_amount)
    else
      $("#deducted_amount_text").prop("readonly", false)
      $("#deducted_amount_text").val("0")

    $("#approve_foc_check").click ->
      if $("#approve_foc_check").is(":checked")
        $("#deducted_amount_text").prop("readonly", true)
        $("#deducted_amount_text").val(deducted_amount)
      else
        $("#deducted_amount_text").prop("readonly", false)
        $("#deducted_amount_text").val("0")

  on_click_adjust_check_visibility: (elem) ->
    this_elem = $(elem)
    $('.adjust_checkbox').change ->
      if @checked
        $(".adjust_container").prop("disabled", false)
      else
        $('.adjust_container').prop("disabled", true)
      return
    return

  unit_returned_checkbox: ->
    $('#content_tag2').data('source')

    if $('#content_tag2').data('source') == 1
      $("#unit_return_customer").prop("disabled", false)
      $("#unit_return_customer").prop("checked", true)
    else if $('#content_tag2').data('source') == 2
      $("#unit_return_customer").prop("disabled", true)
    return

  adjust_checked_visibility: ->
    $('#content_tag1').data('source')

    if $('#content_tag1').data('source') == true
      $(".adjust_checkbox").prop("disabled", false)
    else if $('#content_tag1').data('source') == false
      $(".adjust_checkbox").prop("disabled", true)
      $(".adjust_container").prop("disabled", true)
    return