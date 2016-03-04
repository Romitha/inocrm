# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.Invoices =
  setup: ->
    @quotation_change()
    return

  quotation_change: ->
    total_tax = 0
    total_min_adv_payment = 0
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
        now_min_adv_payment_val = $(@).parents("tr").find(".min_adv_payment").text()
        total_min_adv_payment += parseFloat(now_min_adv_payment_val)

        now_val = $(@).parents("tr").find(".tax").text()
        total_tax += parseFloat(now_val)

        now_total_amount_val = $(@).parents("tr").find(".total_amount").text()
        total_amount += parseFloat(now_total_amount_val)

    $("#total_min_adv_payment").html(total_min_adv_payment)
    $("#total_tax").html(total_tax)
    $("#total_amount").html(total_amount)
    final_total_amount = total_amount + total_tax
    # final_total_amount = parseFloat($("#total_amount").text) + parseFloat($("#total_tax").text)
    $("#final_total_amount").html(final_total_amount)

    $(".action").click ->
      if $(@).is(":checked")

        now_min_adv_payment_val1 =  parseFloat($(@).parents("tr").find(".min_adv_payment").text())
        total_min_adv_payment = parseFloat($("#total_min_adv_payment").text()) + now_min_adv_payment_val1
        $("#total_min_adv_payment").html(total_min_adv_payment)

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
          total_min_adv_payment = parseFloat($("#total_min_adv_payment").text()) - now_min_adv_payment_val1
          $("#total_min_adv_payment").html(total_min_adv_payment)
        else
          $("#total_min_adv_payment").html(total_min_adv_payment)


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
    if $("#ticket_close_approved_check").is(":checked")
      $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)
    else
      $("#close_approve_reject_reason").addClass("hide").prop("disabled", true)

    $("#ticket_close_approved_check").click ->
      if $(@).is(":checked")
        $("#close_approve_reject_reason").removeClass("hide").prop("disabled", false)
      else
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
        $("#close_approve_reject_reason").addClass("hide").prop("disabled", true)