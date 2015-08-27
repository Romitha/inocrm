class InventoriesController < ApplicationController

  def inventory_in_modal
    Inventory
    session[:select_frame] = params[:select_frame]
    if params[:select_inventory] and params[:inventory_id] and session[:select_frame]
      @inventory = Inventory.find params[:inventory_id]

      if session[:select_frame] == "request_from"
        session[:store_id] = @inventory.store_id
        session[:inv_product_id] = @inventory.product_id

      elsif session[:select_frame] == "main_product"
        session[:mst_store_id] = @inventory.store_id
        session[:mst_inv_product_id] = @inventory.product_id

      end
    end
  end

  def search_inventories
    respond_to do |format|

      @display_results = true
      parent_query = params[:search_inventory].except("brand", "product", "mst_inv_product").to_hash
      mst_inv_product = params[:search_inventory].except("brand", "product")["mst_inv_product"].to_hash.delete_if { |k, v| v.blank? }
      @inventories = []
      if mst_inv_product.present?
        @inventories = Inventory.includes(:inventory_product).where(parent_query.merge(mst_inv_product: mst_inv_product))
      else
        @inventories = Inventory.where(parent_query)
      end
      format.js {render :inventory_in_modal}
    end
  end

  def update_part_order

    ticket_spare_part = TicketSparePart.find params[:ticket_spare_part_id]
    @ticket = ticket_spare_part.ticket

    ticket_spare_part.update(ticket_spare_part_params(ticket_spare_part))

    continue = true

    save_ticket_spare_part = Proc.new do |spare_part_status, action_id_no|

      ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code(spare_part_status).id

      ticket_spare_part.ticket_spare_part_status_actions.create(status_id: ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

      action_id = TaskAction.find_by_action_no(action_id_no).id
      user_ticket_action = ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_spare_part.ticket.re_open_count, action_id: action_id)

      user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part.id)

      user_ticket_action.save
    end

    # ticket_id, process_id, task_id should not be null
    # http://0.0.0.0:3000/tickets/assign-ticket?ticket_id=2&process_id=212&owner=supp_mgr&task_id=191
    if params[:task_id] and params[:process_id] and params[:owner]

      bpm_response = view_context.send_request_process_data process_history: true, process_instance_id: params[:process_id], variable_id: "ticket_id"

      if bpm_response[:status].upcase == "ERROR"
        continue = false
        @flash_message = "Bpm error."
      end

    else
      continue = false
    end

    manufacture_warranty = ticket_spare_part.ticket_spare_part_manufacture.present?
    store_warranty = (ticket_spare_part.ticket_spare_part_store and not ticket_spare_part.cus_chargeable_part)
    store_non_warranty = (ticket_spare_part.ticket_spare_part_store and ticket_spare_part.cus_chargeable_part)

    rce = ticket_spare_part.spare_part_status_action.code == "RCE" # Received by Engineer
    rpr = ticket_spare_part.spare_part_status_action.code == "RPR" # Returned Part Reject
    rqt = ticket_spare_part.spare_part_status_action.code == "RQT" # Requested
    str = ticket_spare_part.spare_part_status_action.code == "STR" # Request from Store
    ecm = ticket_spare_part.spare_part_status_action.code == "ECM" # Estimation Completed
    cea = ticket_spare_part.spare_part_status_action.code == "CEA" # Cus. Estimation Approved
    iss = ticket_spare_part.spare_part_status_action.code == "ISS" # Issued
    
    if params[:terminate]
      if (manufacture_warranty and rqt) or (store_warranty and str) or (store_non_warranty and (rqt or ecm or cea))

        save_ticket_spare_part["CLS", 19]

        @flash_message = "Termination is successfully done."
      end
    
    elsif params[:return]

      if continue
        if manufacture_warranty and (rce or rpr)

          save_ticket_spare_part["RTN", 17]

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d32_return_manufacture_part: "Y")

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          # bpm output variables
          ticket_id = @ticket.id
          request_spare_part_id = ticket_spare_part.id
          supp_engr_user = current_user.id
          priority = @ticket.priority

          # Create Process "SPPT_MFR_PART_RETURN", 
          bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_MFR_PART_RETURN", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}

          if bpm_response1[:status].try(:upcase) == "SUCCESS"
            @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
            ticket_bpm_headers bpm_response1[:process_id], @ticket.id, ""
          else
            @bpm_process_error = true
          end

          if bpm_response[:status].upcase == "SUCCESS"
            @flash_message = "Successfully updated."
          else
            @flash_message = "ticket is updated. but Bpm error"
          end
          
          @flash_message = "#{@flash_message} Unable to start new process." if @bpm_process_error

        elsif (store_warranty and (rce or rpr)) or (store_non_warranty and (rce or rpr))

          save_ticket_spare_part["RTN", 17]

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d24_return_store_part: "Y")

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          # bpm output variables
          ticket_id = @ticket.id
          request_spare_part_id = ticket_spare_part.id
          supp_engr_user = current_user.id
          priority = @ticket.priority
          request_onloan_spare_part_id = '-'
          onloan_request = "N"

          # Create Process "SPPT_STORE_PART_RETURN", 
          bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_RETURN", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}

          if bpm_response1[:status].try(:upcase) == "SUCCESS"
            @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
            ticket_bpm_headers bpm_response1[:process_id], @ticket.id, ""
          else
            @bpm_process_error = true
          end

          if bpm_response[:status].upcase == "SUCCESS"
            @flash_message = "Successfully updated."
          else
            @flash_message = "ticket is updated. but Bpm error"
          end
          
          @flash_message = "#{@flash_message} Unable to start new process." if @bpm_process_error

        end
      end


    elsif params[:store_request]

      if continue
        if store_non_warranty and cea

          save_ticket_spare_part["STR", 15]

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d17_request_store_part: "Y")

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          # bpm output variables
          ticket_id = @ticket.id
          request_spare_part_id = ticket_spare_part.id
          supp_engr_user = current_user.id
          priority = @ticket.priority
          request_onloan_spare_part_id = '-'
          onloan_request = "N"

          # Create Process "SPPT_STORE_PART_REQUEST", 
          bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_REQUEST", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}

          if bpm_response1[:status].try(:upcase) == "SUCCESS"
            @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
            ticket_bpm_headers bpm_response1[:process_id], @ticket.id, ""
          else
            @bpm_process_error = true
          end

          if bpm_response[:status].upcase == "SUCCESS"
            @flash_message = "Successfully updated."
          else
            @flash_message = "ticket is updated. but Bpm error"
          end
          
          @flash_message = "#{@flash_message} Unable to start new process." if @bpm_process_error

        end
      end    

    elsif params[:recieved]

      if iss and (manufacture_warranty or store_warranty or store_non_warranty)

        save_ticket_spare_part["RCE", 16]

      end
    end
    redirect_to todos_url, notice: @flash_message
  end

  def update_onloan_part_order
    
    ticket_on_loan_spare_part = TicketOnLoanSparePart.find params[:ticket_on_loan_spare_part_id]
    @ticket = ticket_on_loan_spare_part.ticket

    continue = true

    save_ticket_on_loan_spare_part = Proc.new do |onloan_spare_part_status, action_id_no|

      ticket_on_loan_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code(onloan_spare_part_status).id

      ticket_on_loan_spare_part.ticket_on_loan_spare_part_status_actions.create(status_id: ticket_on_loan_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

      action_id = TaskAction.find_by_action_no(action_id_no).id
      user_ticket_action = ticket_on_loan_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_on_loan_spare_part.ticket.re_open_count, action_id: action_id)

      user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: ticket_on_loan_spare_part.id)

      user_ticket_action.save
    end

    # ticket_id, process_id, task_id should not be null
    # http://0.0.0.0:3000/tickets/assign-ticket?ticket_id=2&process_id=212&owner=supp_mgr&task_id=191
    if params[:task_id] and params[:process_id] and params[:owner]

      bpm_response = view_context.send_request_process_data process_history: true, process_instance_id: params[:process_id], variable_id: "ticket_id"

      if bpm_response[:status].upcase == "ERROR"
        continue = false
        @flash_message = "Bpm error."
      end

    else
      continue = false
    end

    str = ticket_on_loan_spare_part.spare_part_status_action.code == "STR" # Request from Store
    aps = ticket_on_loan_spare_part.spare_part_status_action.code == "APS" # Approved Store Request
    rjs = ticket_on_loan_spare_part.spare_part_status_action.code == "RJS" # Reject Store Request   
    iss = ticket_on_loan_spare_part.spare_part_status_action.code == "ISS" # Issued
    rce = ticket_on_loan_spare_part.spare_part_status_action.code == "RCE" # Received by Engineer
    rtn = ticket_on_loan_spare_part.spare_part_status_action.code == "RTN" # Part Return by Engineer
    rpr = ticket_on_loan_spare_part.spare_part_status_action.code == "RPR" # Returned Part Reject
    rpa = ticket_on_loan_spare_part.spare_part_status_action.code == "RPA" # Returned Part Accepted
    cls = ticket_on_loan_spare_part.spare_part_status_action.code == "CLS" # Closed
   
    
    if params[:terminate]
      if str
        save_ticket_on_loan_spare_part["CLS", 53]
        @flash_message = "Terminate action is Successfully done."
      end
    
    elsif params[:return]

      if continue
        if rce or rpr

          save_ticket_on_loan_spare_part["RTN", 52]

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d24_return_store_part: "Y", onloan_request: "Y")

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          # bpm output variables
          ticket_id = @ticket.id
          request_spare_part_id = '-'
          supp_engr_user = current_user.id
          priority = @ticket.priority
          request_onloan_spare_part_id = ticket_on_loan_spare_part.id
          onloan_request = "Y"

          # Create Process "SPPT_STORE_PART_RETURN", 
          bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_RETURN", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}

          if bpm_response1[:status].try(:upcase) == "SUCCESS"
            @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
            ticket_bpm_headers bpm_response1[:process_id], @ticket.id, ""
          else
            @bpm_process_error = true
          end

          if bpm_response[:status].upcase == "SUCCESS"
            @flash_message = "Successfully updated."
          else
            @flash_message = "ticket is updated. but Bpm error"
          end
          
          @flash_message = "#{@flash_message} Unable to start new process." if @bpm_process_error

        end
      end


    elsif params[:recieved]

      if iss
        save_ticket_on_loan_spare_part["RCE", 51]
        @flash_message = "Recieve action is Successfully done."
      end
    end
    redirect_to todos_url, notice: @flash_message
  end

  def load_estimation
    @estimation_type = params[:estimation_type]
    @estimation = TicketEstimation.find params[:estimation_id]
  end

  def update_estimation_customer_approval
    @estimation = TicketEstimation.find estimation_params[:id]

    if @estimation.update estimation_params.merge(cust_approved_at: DateTime.now)

      @flash_message = {notice: "Sorry! unable to update"}
    else

      @flash_message = {error: "Sorry! unable to update"}
    end
    redirect_to todos_url, @flash_message
  end

  private
    def ticket_spare_part_params ticket_spare_part
      t_spare_part = params.require(:ticket_spare_part).permit(:spare_part_no, :spare_part_description, :ticket_id, :ticket_fsr, :cus_chargeable_part, :request_from, :faulty_serial_no, :faulty_ct_no, :note, :status_action_id, :part_terminated, :status_use_id, ticket_attributes: [:remarks, :id])
      t_spare_part[:note] = t_spare_part[:note].present? ? "#{t_spare_part[:note]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_spare_part.note}" : ticket_spare_part.note

      t_spare_part
    end

    def estimation_params
      params.require(:ticket_estimation).permit(:note, :id, :cust_approved, :cust_approved_by)
    end
end