# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.Invoices =
  setup: ->
    @quotation_change()
    @check_fsr_dynamic_check_behavour()
    @enable_ticket_payment_received_in_customer_feedback()
    @customer_feedback_re_opened()
    return

  quotation_change: ->
    total_tax = 0
    amount_to_be_paid = 0
    total_amount = 0
    final_total_amount = 0

    $(".action").each ->
      additional_charge = parseFloat($(@).parents("tr").find(".additional").text())
      total_amount = parseFloat($(@).parents("tr").find(".total_amount").text())
      tax = parseFloat($(@).parents("tr").find(".tax").text())
      amount = additional_charge + total_amount + tax
      $(@).parents("tr").find(".amount").html(amount)

    $(".action").each ->
      if $(@).is(":checked")
        now_total_amount = parseFloat($(@).parents("tr").find(".total_amount").text())
        now_tax = parseFloat($(@).parents("tr").find(".tax").text())
        now_amount_to_be_paid = now_total_amount - now_tax
        amount_to_be_paid += parseFloat(now_amount_to_be_paid)

        now_val = $(@).parents("tr").find(".tax").text()
        total_tax += parseFloat(now_val)

        now_total_amount_val = $(@).parents("tr").find(".total_amount").text()
        total_amount += parseFloat(now_total_amount_val)

    $("#amount_to_be_paid").html(amount_to_be_paid)
    $("#total_tax").html(total_tax)
    $("#total_amount").html(total_amount)
    final_total_amount = total_amount + total_tax
    # final_total_amount = parseFloat($("#total_amount").text) + parseFloat($("#total_tax").text)
    $("#final_total_amount").html(final_total_amount)

    $(".action").click ->
      if $(@).is(":checked")

        now_total_amount =  parseFloat($(@).parents("tr").find(".total_amount").text())
        now_tax =  parseFloat($(@).parents("tr").find(".tax").text())
        now_amount_to_be_paid = now_total_amount - now_tax
        amount_to_be_paid = parseFloat($("#amount_to_be_paid").text()) + now_amount_to_be_paid
        $("#amount_to_be_paid").html(amount_to_be_paid)

        now_val1 =  parseFloat($(@).parents("tr").find(".tax").text())
        total_tax = parseFloat($("#total_tax").text()) + now_val1
        $("#total_tax").html(total_tax)

        now_total_amount_val1 =  parseFloat($(@).parents("tr").find(".total_amount").text())
        total_amount = parseFloat($("#total_amount").text()) + now_total_amount_val1
        $("#total_amount").html(total_amount)

        final_total_amount = total_amount + total_tax
        $("#final_total_amount").html(final_total_amount)

      else

        now_min_adv_payment_val1 =  parseFloat($(@).parents("tr").find(".min_adv_payment").text())
        if now_min_adv_payment_val1 >= 0
          amount_to_be_paid = parseFloat($("#amount_to_be_paid").text()) - now_min_adv_payment_val1
          $("#amount_to_be_paid").html(amount_to_be_paid)
        else
          $("#amount_to_be_paid").html(amount_to_be_paid)


        now_val1 = parseFloat($(@).parents("tr").find(".tax").text())
        if now_val1 >= 0
          total_tax = parseFloat($("#total_tax").text()) - now_val1
          $("#total_tax").html(total_tax)
        else
          $("#total_tax").html(total_tax)

        now_total_amount_val1 = parseFloat($(@).parents("tr").find(".total_amount").text())
        if now_total_amount_val1 >= 0
          total_amount = parseFloat($("#total_amount").text()) - now_total_amount_val1
          $("#total_amount").html(total_amount)
        else
          $("#total_amount").html(total_amount)

        final_total_amount = total_amount + total_tax
        $("#final_total_amount").html(final_total_amount)

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