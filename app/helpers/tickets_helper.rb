module TicketsHelper
  def re_open_ticket(ticket_id, re_open_action_id, engineer_id=nil)
    ticket = Ticket.find ticket_id

    start_engineer = ticket.ticket_engineers.find engineer_id if engineer_id.present?

    #Create ticket_engineers table for re-open
    eng_map = []
    ticket.ticket_engineers.each do |engineer|

      go_ahead = false
      if engineer_id.present?
        go_ahead = true if (engineer.channel_no = start_engineer.channel_no) and (engineer.order_no >= start_engineer.order_no)
      else
        go_ahead = true 
      end

      if engineer.re_open_index == 0 and go_ahead

        new_engineer = ticket.ticket_engineers.create user_id: engineer.user_id, sbu_id: engineer.sbu_id, created_at: DateTime.now, created_action_id: re_open_action_id, re_open_index: ticket.re_open_count, re_assignment_requested: engineer.re_assignment_requested, channel_no: engineer.channel_no, order_no: engineer.order_no

        old_eng_id = engineer.id
        new_eng_id = new_engineer.id

        eng_map << [old_eng_id, new_eng_id]

        old_parent_engineer_id = engineer.parent_engineer_id
        if old_parent_engineer_id.present?
          new_parent_engineer_id = eng_map.select{|eng_ids| eng_ids.first.to_i == old_parent_engineer_id.to_i }.flatten.last
          new_engineer.update parent_engineer_id: new_parent_engineer_id
        end
      end
    end

    #Remove reassignment requested engineers
    go_ahead = true
    do while go_ahead
      go_ahead = false
      ticket.ticket_engineers.each do |engineer|
        if engineer.re_assignment_requested = true
          go_ahead = true
          assn_eng = engineer
          assn_eng_prnt_id = engineer.parent_engineer_id
        end
      end

      if go_ahead
        ticket.ticket_engineers.each do |engineer|
          if engineer.parent_engineer_id = assn_eng.id
            engineer.update parent_engineer_id: assn_eng_prnt_id
          end
        end
        assn_eng.delete
      end
    end

    #Call BPM
          all_success = true
          error_engs =


            @ticket.ticket_engineers.each do |ticket_engineer|
              unless (ticket_engineer.parent_engineer.present?) and (ticket_engineer.re_open_index == ticket.re_open_count )
                # bpm output variables
                ticket_id = @ticket.id
                di_pop_approval_pending = "N"
                priority = @ticket.priority
                d42_assignment_required = "N"
                engineer_id = ticket_engineer.id

                supp_engr_user = ticket_engineer.user_id
                supp_hd_user = @ticket.created_by

                @bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT", query: {ticket_id: ticket_id, d1_pop_approval_pending: di_pop_approval_pending, priority: priority, d42_assignment_required: d42_assignment_required, engineer_id: engineer_id , supp_engr_user: supp_engr_user, supp_hd_user: supp_hd_user}

                if @bpm_response1[:status].try(:upcase) == "SUCCESS"
                  workflow_process = @ticket.ticket_workflow_processes.create(process_id: @bpm_response[:process_id], process_name: @bpm_response[:process_name])

                  ticket_engineer.status = 1
                  ticket_engineer.job_assigned_at = DateTime.now
                  ticket_engineer.workflow_process_id = workflow_process.process_id

                  ticket_engineer.save

                else
                  all_success = false
                  @bpm_process_error = true
                  error_engs += engineer_id+", "
                end

              end
            end


          unless all_success
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. Engineer assignment error. ("+error_engs+")"
          end

  end
end
