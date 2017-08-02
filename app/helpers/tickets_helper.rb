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


  # def send_email(to_addresses, cc_addresses, ticket_id, spare_part_id, onloan, engineer_id,  email_code)

  #     ticket =  Ticket.find_by_id(ticket_id)
  #     spare_part = TicketSparePart.find_by_id(spare_part_id)
  #     engineer = TicketEngineer.find_by_id(engineer_id)
       
  #     #Customer
  #     customer_name = ticket.cutomer.title.try  + ticket.cutomer.name
  #     customer_address = ticket.cutomer.address1.try + ‘, ’+ ticket.cutomer.address2.try + ‘, ’+ ticket.cutomer.address3.try + ‘, ’+ ticket.cutomer.address4.try
  #     customer_code = ticket.cutomer.organization.account.code.try
  #     customer_contact_person_name = ticket.contact_person1.contact_report_person.title + ticket.contact_person1.contact_report_person.name
       
  #     #ticket
  #     ticket_no = ticket.no
  #     ticket_logged_at = ticket.logged_at
  #     ticket_logged_by = ticket.logged_by
  #     ticket_contract_no = ticket.contact.contract_no
  #     ticket_type = ticket.ticket_type = IH ? “in-house” : ”on-site”
  #     ticket_informed_method = ticket. informed_method.name
  #     ticket_problem_description = ticket. problem_description
       
  #     ticket_product_brand = ticket.
  #     ticket_product_category = ticket.
  #     ticket_product_name = ticket.
  #     ticket_product_serial_no = ticket.
       
  #     #Job Completed
       
  #     ticket_Job_completed_at = ticket.
  #     ticket_Dispatch_method = ticket.
       
  #     #spare Part
       
  #     spare_part_no = spare_part.no
  #     spare_part_name = spare_part.description
  #     if onloan
  #        spare_part_type =  “Onloan”
  #     else
  #       spare_part_type =  “Store” if spare_part.store.present?
  #       spare_part_type =  “Manufacture” if spare_part.manufacture.present?
  #     end
       
  #     #assign_engineer
       
  #     engineer_name = engineer.user.name
  #     assigned_at = engineer. job_assigned_at
  #     assigned_by = engineer.created_action.action_by.user.name
  #     task_description = engineer.task_description
       
  #     email =  mst_spt_template_email.findby(email_code)
  #     if email.present? and email.active
  #        mail_subject = email.subject 
  #        #replace by above variables
  #        mail_body = email.body 
  #        #replace by above variables
  #        Emal send with to_addresses and cc_addresses
  #     end

  # end 

end
