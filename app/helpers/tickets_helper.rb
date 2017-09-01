module TicketsHelper
  def convert_hours_minutes(value)
    result_array = []
    a, b = value.to_f.divmod(3600)
    result_array << "Hours: #{a}"

    if b/60 > 1
      result_array << "Minutes: #{b.to_f.divmod(60).first}"
      result_array << "Seconds: #{b.to_i.divmod(60).last}"
    else
      result_array << "Seconds: #{b.to_i}"
    end

    result_array.join(" ")

  end

  # def constant_variables
  #   new_ticket_code = ”NEW_TICKET”
  #   job_completed_code = ”COMPLETE_JOB”
  #   assign_job_code  = “ASSIGN_JOB”
  #   part_issued_code = “PART_ISSUED”
    
  # end

  def send_email(*args)
    WorkflowMapping

    options = args.extract_options!

    ticket_id = options[:ticket_id]
    spare_part_id = options[:spare_part_id]
    engineer_id = options[:engineer_id]
    onloan = options[:onloan]
    email_code = options[:email_code]
    email_to = options[:email_to]
    email_cc = options[:email_cc]

    ticket =  Ticket.find_by_id(ticket_id)
    spare_part = TicketSparePart.find_by_id(spare_part_id)
    engineer = TicketEngineer.find_by_id(engineer_id)

    body_merger = {}

    if ticket.present?
      customer_info = {customer_name: ticket.customer.full_name, customer_address: ticket.customer.full_address, customer_code: (ticket.customer.organization and ticket.customer.organization.account.code), customer_contact_person_name: ticket.contact_person1.full_name }

      body_merger.merge!(customer_info)

      ticket_info = {ticket_owner_engineer: ticket.owner_engineer.try(:full_name), ticket_resolution: ticket.resolution_summary, ticket_no: ticket.ticket_no, ticket_logged_at: ticket.logged_at.try(:strftime, INOCRM_CONFIG["short_date_format"]),ticket_logged_by: ticket.logged_by_user, ticket_priority: INOCRM_CONFIG["priority"].key(ticket.priority), ticket_informed_method: ticket.inform_method.try(:name), ticket_product_name: ticket.products.first.name, ticket_problem_description: ticket.problem_description, ticket_product_brand: ticket.products.first.brand_name, ticket_product_category: ticket.products.first.category_name, ticket_product_serial_no: ticket.products.first.serial_no }

      body_merger.merge!(ticket_info)

      ticket_contract =  ticket.ticket_contract.present? ? {ticket_contract_no: ticket.ticket_contract.contract_no, contract_type: ticket.ticket_contract.ticket_contract_type.try(:name), contract_start_at: ticket.ticket_contract.contract_start_at.try(:strftime, INOCRM_CONFIG['short_date_format']), contract_end_at: ticket.ticket_contract.contract_end_at.try(:strftime, INOCRM_CONFIG['short_date_format']), contract_active: (ticket.ticket_contract.try(:dynamic_active) ? "Yes" : "No")} : {}

      body_merger.merge!(ticket_contract)

      job_completed_info = {ticket_job_completed_at: ticket.job_finished_at.try(:string,INOCRM_CONFIG["short_date_format"] ), ticket_dispatch_method: "ticket."}

      body_merger.merge!(job_completed_info)

    end

    if spare_part.present?
      spare_part_type = case
      when onloan
        "Onloan"
      when spare_part.ticket_spare_part_store.present?
        "Store"
      when spare_part.ticket_spare_part_manufacture.present?
        "Manufacture"
      end

      spare_part_info = {spare_part_no: spare_part.spare_part_no, spare_part_name: spare_part.spare_part_description, spare_part_type: spare_part_type}

      body_merger.merge!(spare_part_info)

    end

    if engineer.present?
      engineer_info = {engineer_name: engineer.user.full_name, assigned_at: engineer.job_assigned_at.try(:strftime, INOCRM_CONFIG["short_date_format"]) , assigned_by: User.cached_find_by_id(engineer.user_ticket_action.try(:action_by)).full_name, task_description: engineer.task_description }

      body_merger.merge!(engineer_info)

    end

    email = EmailTemplate.find_by_code(email_code)

    if email.present? and email.active
      reprocessed_email_body = email.body.to_s.gsub(/#\w+/){ |s| body_merger[s[1..-1].to_sym] }
      reprocessed_email_subject = email.subject.to_s.gsub(/#\w+/){ |s| body_merger[s[1..-1].to_sym] }

      if EmailTemplate.find_by_code(email_code).try(:active)
        UserMailer.welcome_email(to: email_to, cc: email_cc, subject: reprocessed_email_subject, body: reprocessed_email_body).deliver_now
      end

    end

  end

end
