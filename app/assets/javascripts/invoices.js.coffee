window.Invoices =
  setup: ->
    @quotation_change()
    @check_fsr_dynamic_check_behavour()
    @customer_feedback_re_opened()
    @readonly_checkbox_in_customer_feedback()
    @activate_deducted_amount_terminate_foc()
    return

  quotation_change: ->
    total_tax = 0
    sub_amount = 0
    min_adv_payment = 0
    total_payment = 0
    prev_deduction = 0
    prev_amount_to_be_paid = 0

    total_deduction = if !$("#deducted_amount").val() or isNaN(parseFloat($("#deducted_amount").val())) then 0 else parseFloat($("#deducted_amount").val())

    $("#total_deduction").text(total_deduction)
    $("#total_deduction_value").val(total_deduction)

    $(".total_payment").each ->
      total_payment += if isNaN(parseFloat($(@).text())) then 0 else parseFloat($(@).text())

    $(".action").each ->
      if $(@).is(":checked")
        sub_amount += if isNaN(parseFloat($(@).parent().siblings(".sub_amount").text())) then 0.0 else parseFloat($(@).parent().siblings(".sub_amount").text())
        total_tax += if isNaN(parseFloat($(@).parent().siblings(".tax").text())) then 0 else parseFloat($(@).parent().siblings(".tax").text())
        min_adv_payment += if isNaN(parseFloat($(@).parent().siblings(".min_adv_payment").text())) then 0 else parseFloat($(@).parent().siblings(".min_adv_payment").text())

    final_total_amount = sub_amount + total_tax
    amount_to_be_paid = final_total_amount - total_payment - total_deduction

    $("#deducted_amount").keyup ->
      _this = this
      setTimeout ( ->
        total_deduction = if !$(_this).val() or isNaN(parseFloat($(_this).val())) then 0 else parseFloat($(_this).val())
        $("#total_deduction").text(total_deduction)
        $("#total_deduction_value").val(total_deduction)

        amount_to_be_paid = final_total_amount - total_payment - parseFloat(total_deduction)
        $("#amount_to_be_paid").text(Math.round(amount_to_be_paid * 100)/100)
        $("#amount_to_be_paid_value").val(Math.round(amount_to_be_paid * 100)/100)
        $("#total_amount_value").val(total_deduction)
      ), 200

    $("#amount_to_be_paid").text(Math.round(amount_to_be_paid * 100)/100)
    $("#amount_to_be_paid_value").val(Math.round(amount_to_be_paid * 100)/100)
    $("#total_amount_value").val(total_deduction)

    $("#total_tax").text(total_tax)
    $("#total_tax_value").val(total_tax)

    $("#sub_amount").text(sub_amount)
    $("#sub_amount_value").val(sub_amount)
    $("#final_total_amount").text(final_total_amount)
    $("#min_adv_payment").text(min_adv_payment)
    $("#total_payment").text(total_payment)
    $("#total_payment_value").val(total_payment)

    $(".action").click ->
      # total_tax = 0
      # sub_amount = 0
      if $(@).is(":checked")
        sub_amount += if isNaN(parseFloat($(@).parent().siblings(".sub_amount").text())) then 0 else parseFloat($(@).parent().siblings(".sub_amount").text())
        total_tax += if isNaN(parseFloat($(@).parent().siblings(".tax").text())) then 0 else parseFloat($(@).parent().siblings(".tax").text())
        min_adv_payment += if isNaN(parseFloat($(@).parent().siblings(".min_adv_payment").text())) then 0 else parseFloat($(@).parent().siblings(".min_adv_payment").text())
      else
        sub_amount -= if isNaN(parseFloat($(@).parent().siblings(".sub_amount").text())) then 0 else parseFloat($(@).parent().siblings(".sub_amount").text())
        total_tax -= if isNaN(parseFloat($(@).parent().siblings(".tax").text())) then 0 else parseFloat($(@).parent().siblings(".tax").text())
        min_adv_payment -= if isNaN(parseFloat($(@).parent().siblings(".min_adv_payment").text())) then 0 else parseFloat($(@).parent().siblings(".min_adv_payment").text())

      final_total_amount = sub_amount + total_tax
      amount_to_be_paid = final_total_amount - total_payment - total_deduction

      $("#amount_to_be_paid").text(Math.round(amount_to_be_paid * 100)/100)
      $("#amount_to_be_paid_value").val(Math.round(amount_to_be_paid * 100)/100)
      $("#total_tax").text(total_tax)
      $("#sub_amount").text(sub_amount)
      $("#sub_amount_value").val(sub_amount)
      $("#final_total_amount").text(final_total_amount)
      $("#min_adv_payment").text(min_adv_payment)
      $("#total_payment").text(total_payment)
      $("#total_payment_value").val(total_payment)

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
    if $("#approve_foc_check").is(":checked")
      $("#deducted_amount_text").prop("disabled", true)
    else
      $("#deducted_amount_text").prop("disabled", false)

    $("#approve_foc_check").click ->
      if $("#approve_foc_check").is(":checked")
        $("#deducted_amount_text").prop("disabled", true)
      else
        $("#deducted_amount_text").prop("disabled", false)