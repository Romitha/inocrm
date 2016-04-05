window.Invoices =
  setup: ->
    @quotation_change()
    @check_fsr_dynamic_check_behavour()
    @enable_ticket_payment_received_in_customer_feedback()
    @customer_feedback_re_opened()
    return

  quotation_change: ->
    total_tax = 0
    sub_amount = 0
    min_adv_payment = 0
    total_payment = 0

    total_deduction = parseFloat($("#deducted_amount").val())
    $("#deducted_amount").keyup ->
      $("#total_deduction").html(total_deduction)

    $(".total_payment").each ->
      total_payment += parseFloat($(@).text())

    $(".action").each ->
      if $(@).is(":checked")
        sub_amount += parseFloat($(@).parent().siblings(".sub_amount").text())
        total_tax += parseFloat($(@).parent().siblings(".tax").text())
        min_adv_payment += parseFloat($(@).parent().siblings(".min_adv_payment").text())

    final_total_amount = sub_amount + total_tax
    amount_to_be_paid = final_total_amount - total_payment - total_deduction

    $("#amount_to_be_paid").html(amount_to_be_paid)
    $("#total_tax").html(total_tax)
    $("#sub_amount").html(sub_amount)
    $("#final_total_amount").html(final_total_amount)
    $("#min_adv_payment").html(min_adv_payment)
    $("#total_payment").html(total_payment)



    $(".action").click ->
      total_tax = 0
      sub_amount = 0
      sub_amount = 0
      total_deduction = parseFloat($("#total_deduction").text())

      $(".action").each ->
        if $(@).is(":checked")
          sub_amount += parseFloat($(@).parent().siblings(".sub_amount").text())
          total_tax += parseFloat($(@).parent().siblings(".tax").text())
          min_adv_payment += parseFloat($(@).parent().siblings(".min_adv_payment").text())

      final_total_amount = sub_amount + total_tax
      amount_to_be_paid = final_total_amount - total_payment - total_deduction

      $("#amount_to_be_paid").html(amount_to_be_paid)
      $("#total_tax").html(total_tax)
      $("#sub_amount").html(sub_amount)
      $("#final_total_amount").html(final_total_amount)
      $("#min_adv_payment").html(min_adv_payment)
      $("#total_payment").html(total_payment)

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

  enable_ticket_payment_received_in_customer_feedback: ->
    $("#re_open").click ->
      if $(@).is(":checked")
        $("#ticket_payment_reciever_wrapper").addClass("hide")
      else
        $("#ticket_payment_reciever_wrapper").removeClass("hide")

  customer_feedback_re_opened: ->
    $("#re_opened").change ->
      if $(@).is(":checked")
        $("#unit_return_customer").prop("disabled", true)
        $("#dispatch_method_id").prop("disabled", true)
        $("#unit_dispatch_wrapper").addClass("hide")
      else
        $("#unit_dispatch_wrapper").removeClass("hide")
        $("#dispatch_method_id").prop("disabled", false)
        $("#unit_return_customer").prop("disabled", false)