class InventoriesController < ApplicationController

  before_action :find_ticket, only: [:update_low_margin_estimate, :update_estimate_job, :update_delivery_unit]

  def inventory_in_modal
    Inventory
    Grn
    session[:select_frame] = params[:select_frame]
    if params[:select_inventory] and (params[:inventory_id] or params[:inventory_product_id]) and session[:select_frame]
      @inventory = Inventory.find params[:inventory_id] if params[:inventory_id]
      @inventory_product = InventoryProduct.find params[:inventory_product_id] if params[:inventory_product_id]

      if session[:select_frame] == "request_from"
        if @inventory
          session[:store_id] = @inventory.store_id
          session[:inv_product_id] = @inventory.product_id
        elsif @inventory_product
          session[:store_id] = session[:requested_store_id]
          session[:inv_product_id] = @inventory_product.id
        end

      elsif session[:select_frame] == "main_product"

        if @inventory
          session[:mst_store_id] = @inventory.store_id
          session[:mst_inv_product_id] = @inventory.product_id
        elsif @inventory_product
          session[:mst_store_id] = session[:requested_store_id]
          session[:mst_inv_product_id] = @inventory_product.id
        end
        # session[:mst_store_id] = @inventory.store_id
        # session[:mst_inv_product_id] = @inventory.product_id

      end
      if params[:issue_part] == "true"
        approved_inventory_product = (@inventory_product || @inventory.inventory_product)
        if approved_inventory_product.fifo
          @main_part_serial = approved_inventory_product.inventory_serial_items.includes(:inventory).where(inv_inventory: {store_id: session[:requested_store_id].to_i}, inv_status_id: InventorySerialItemStatus.find_by_code("AV").id).sort{|p, n| p.grn_items.last.grn.created_at <=> n.grn_items.last.grn.created_at}
        else
          @main_part_serial = approved_inventory_product.inventory_serial_items.includes(:inventory).where(inv_inventory: {store_id: session[:requested_store_id].to_i}, inv_status_id: InventorySerialItemStatus.find_by_code("AV").id).sort{|p, n| p.grn_items.last.grn.created_at <=> n.grn_items.last.grn.created_at}
        end
      end
    end
  end

  def search_inventories
    Inventory
    respond_to do |format|

      query_hash = {}
      @display_results = true
      store_hash = params[:search_inventory].except("brand", "product", "mst_inv_product").to_hash
      session[:requested_store_id] = store_hash["store_id"].to_i

      mst_inv_product = params[:search_inventory].except("brand", "product")["mst_inv_product"].to_hash.delete_if { |k, v| v.blank? }

      # many_mst_inv_product = mst_inv_product.inject(""){|i, (k, v)| k != "category3_id" ? i+k+" like '%"+v+"%' and " : i+k+" = "+v+" and "}
      mst_inv_product_like = mst_inv_product.map { |v| v.first == "category3_id" ? v.first+" = "+v.last : v.first+" like '%"+v.last+"%'" }.join(" and ")
      mst_inv_product_for_inventory_like = mst_inv_product.map { |v| v.first == "category3_id" ? "mst_inv_product."+v.first+" = "+v.last : "mst_inv_product."+v.first+" like '%"+v.last+"%'" }.join(" and ")
      # a.map{|v| v.first+" like '%"+v.last+"%'"}.join(" and ")
      # @inventories = Inventory.where(store_id: store_hash["store_id"].to_i)
      if params[:select_frame] == "main_product"
        @inventories = Inventory.includes(inventory_product: :inventory_product_info).where(store_id: store_hash["store_id"].to_i, mst_inv_product_info: {need_serial: true}).where(mst_inv_product_for_inventory_like).references(:mst_inv_product)
        avoidable_inventory_product_ids = @inventories.map { |inventory| inventory.product_id }.compact
        @inventory_products = InventoryProduct.where.not(id: avoidable_inventory_product_ids).where(mst_inv_product_like).includes(:inventory_product_info).where(mst_inv_product_info: {need_serial: true})
      else
        @inventories = Inventory.includes(:inventory_product).where(store_id: store_hash["store_id"].to_i).where(mst_inv_product_for_inventory_like).references(:mst_inv_product)
        avoidable_inventory_product_ids = @inventories.map { |inventory| inventory.product_id }.compact
        @inventory_products = InventoryProduct.where.not(id: avoidable_inventory_product_ids).where(mst_inv_product_like)
      end

      format.js {render :inventory_in_modal}
    end
  end

  def update_part_order

    ticket_spare_part = TicketSparePart.find params[:ticket_spare_part_id]
    @ticket = ticket_spare_part.ticket

    ticket_spare_part.update(ticket_spare_part_params(ticket_spare_part))

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    save_ticket_spare_part = Proc.new do |spare_part_status, action_id_no|

      ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code(spare_part_status).id

      ticket_spare_part.ticket_spare_part_status_actions.create(status_id: ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

      action_id = TaskAction.find_by_action_no(action_id_no).id
      user_ticket_action = ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_spare_part.ticket.re_open_count, action_id: action_id)

      user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part.id)

      user_ticket_action.save
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

        flash[:notice] = "Termination is successfully done."
      end
    
    elsif params[:return]

      if not params[:update_without_return]
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
              view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id, request_spare_part_id
            else
              @bpm_process_error = true
            end

            if bpm_response[:status].upcase == "SUCCESS"
              flash[:notice] = "Successfully updated."
            else
              flash[:error] = "ticket is updated. but Bpm error"
            end
            
            flash[:error] = "#{@flash_message} Unable to start new process." if @bpm_process_error

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
              view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id, request_spare_part_id
            else
              @bpm_process_error = true
            end

            if bpm_response[:status].upcase == "SUCCESS"
              flash[:notice] = "Successfully updated."
            else
              flash[:error] = "spare part is updated. but Bpm error"
            end
            
            flash[:error] = "#{@flash_message} Unable to start new process." if @bpm_process_error

          end
        end
      else
        flash[:error] = "spare part is updated"
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
            view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id, request_spare_part_id
          else
            @bpm_process_error = true
          end

          if bpm_response[:status].upcase == "SUCCESS"
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. but Bpm error"
          end
          
          flash[:error] = "#{@flash_message} Unable to start new process." if @bpm_process_error

        end
      else
        flash[:error] = "Bpm error. ticket is not updated"
      end    

    elsif params[:recieved]

      if iss and (manufacture_warranty or store_warranty or store_non_warranty)

        save_ticket_spare_part["RCE", 16]

      end
    end
    redirect_to todos_url
  end

  def update_onloan_part_order
    
    ticket_on_loan_spare_part = TicketOnLoanSparePart.find params[:ticket_on_loan_spare_part_id]
    @ticket = ticket_on_loan_spare_part.ticket

    ticket_on_loan_spare_part.update ticket_on_loan_spare_part_params(ticket_on_loan_spare_part) 

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    save_ticket_on_loan_spare_part = Proc.new do |onloan_spare_part_status, action_id_no|

      ticket_on_loan_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code(onloan_spare_part_status).id

      ticket_on_loan_spare_part.ticket_on_loan_spare_part_status_actions.create(status_id: ticket_on_loan_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

      action_id = TaskAction.find_by_action_no(action_id_no).id
      user_ticket_action = ticket_on_loan_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_on_loan_spare_part.ticket.re_open_count, action_id: action_id)

      user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: ticket_on_loan_spare_part.id)

      user_ticket_action.save
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
            view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id, "", request_onloan_spare_part_id
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
      else
        @flash_message = "Bpm error. ticket is not updated"
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

  def load_estimation_ticket_info
    @estimation_type = params[:estimation_type]
    @estimation = TicketEstimation.find params[:estimation_id]
  end

  def update_estimation_part_customer_approval
    Ticket
    status_action_id = SparePartStatusAction.find_by_code("CLS").id

    @estimation = TicketEstimation.find estimation_params[:id]
    @estimation.attributes = estimation_params

    @estimation.status_id = EstimationStatus.find_by_code("CLS").id
    @estimation.cust_approved_at = DateTime.now
    @estimation.cust_approved_by = current_user.id

    continue = true

    if @estimation.cust_approved
      if ( !@estimation.approval_required and @estimation.advance_payment_amount > 0) or ( @estimation.approval_required and @estimation.approved_adv_pmnt_amount > 0)

        continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

        if continue
          @estimation.status_id = EstimationStatus.find_by_code("APP").id
          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d20_advance_payment_required: "Y", advance_payment_estimation_id: @estimation.id)

          @estimation.ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @estimation.ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"
            @flash_message = {notice: "Successfully updated"}
          else
            @flash_message = {error: "ticket is updated. but Bpm error"}
          end
        else
          @flash_message = "Bpm error. ticket is not updated"
        end
      end

      status_action_id = SparePartStatusAction.find_by_code("CEA").id
    end

    if continue

      @estimation.ticket_estimation_parts.each do |ticket_estimation_part|
        ticket_estimation_part.ticket_spare_part.update(status_action_id: status_action_id)

        ticket_estimation_part.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: status_action_id, done_by: current_user.id, done_at: DateTime.now)
      end

      if @estimation.save

        @flash_message = {notice: "Successfully updated"}
      else

        @flash_message = {error: "Sorry! unable to update"}
      end
    end
    redirect_to todos_url, @flash_message
  end

  def update_estimation_external_customer_approval
    Ticket

    @estimation = TicketEstimation.find estimation_params[:id]
    @estimation.attributes = estimation_params

    @estimation.status_id = EstimationStatus.find_by_code("CLS").id
    @estimation.cust_approved_at = DateTime.now
    @estimation.cust_approved_by = current_user.id

    continue = true

    if @estimation.cust_approved
      if ( !@estimation.approval_required and @estimation.advance_payment_amount > 0) or ( @estimation.approval_required and @estimation.approved_adv_pmnt_amount > 0)

        continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

        if continue
          @estimation.status_id = EstimationStatus.find_by_code("APP").id

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d20_advance_payment_required: "Y", advance_payment_estimation_id: @estimation.id)

          @estimation.ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @estimation.ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"
            @flash_message = {notice: "Successfully updated"}
          else
            @flash_message = {error: "ticket is updated. but Bpm error"}
          end
        else
          @flash_message = "Bpm error. ticket is not updated"
        end
      end
    end

    if continue

      if @estimation.save

        user_ticket_action = @estimation.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(24).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @estimation.ticket.re_open_count)
        user_ticket_action.build_act_job_estimation(supplier_id: @estimation.ticket_estimation_externals.first.try(:organization).try(:id), ticket_estimation_id: @estimation.id)

        user_ticket_action.save

        @flash_message = {notice: "Successfully updated"}
      else

        @flash_message = {error: "Sorry! unable to update"}
      end
    end
    redirect_to todos_url, @flash_message
  end

  def update_estimate_job

    Ticket
    Organization
    @ticket_estimation = TicketEstimation.find params[:ticket_estimation_id]
    @ticket_estimation_external = TicketEstimationExternal.find params[:ticket_estimation_external_id]

    @ticket.update(ticket_params)

    @ticket_estimation.update_attributes(estimated_at: DateTime.now, estimated_by: current_user.id)

    if params[:estimation_completed]

      continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
      d14_val = false

      if continue

        t_cost_price = @ticket_estimation_external.cost_price.to_f + @ticket_estimation.ticket_estimation_additionals.sum(:cost_price).to_f
        t_est_price = @ticket_estimation_external.estimated_price.to_f + @ticket_estimation.ticket_estimation_additionals.sum(:estimated_price).to_f

        if t_est_price > 0
          @ticket_estimation.update_attribute(:cust_approval_required, true)
          d14_val = (((t_est_price - t_cost_price)*100/t_cost_price) < CompanyConfig.first.try(:sup_external_job_profit_margin).to_f)
        else
          @ticket_estimation.update_attribute(:cust_approval_required, false)
          d14_val = false
        end
             
        # Set Action (27) Job Estimation Done, DB.spt_act_job_estimate. Set supp_engr_user = supp_engr_user (Input variable)

        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(27).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_act_job_estimation(ticket_estimation_id: @ticket_estimation.id, supplier_id: @ticket_estimation_external.repair_by_id)

        user_ticket_action.save

        if !d14_val
          @ticket.update_attribute(:status_resolve_id, TicketStatusResolve.find_by_code("EST").id)# (Estimated).
          @ticket_estimation.update_attribute(:status_id, EstimationStatus.find_by_code("EST").id)#EST (Estimated).
        else
          @ticket_estimation.update_attribute(:approval_required, true)
        end       

        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables.merge(d14_job_estimate_external_below_margin: (d14_val ? "Y" : "N"))

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = {notice: "Successfully updated"}
        else
          @flash_message = {error: "ticket is updated. but Bpm error"}
        end
      else
        @flash_message = "Bpm error. ticket is not updated"
      end
    end
    redirect_to todos_url, notice: "Successfully updated."
  end

  def update_low_margin_estimate

    Ticket
    Organization
    @ticket_estimation = TicketEstimation.find params[:ticket_estimation_id]
    @ticket_estimation_external = TicketEstimationExternal.find params[:ticket_estimation_external_id]

    @ticket.update(ticket_params)
    @ticket_estimation.update_attributes(approved_at: DateTime.now, approved_by: current_user.id)

    if params[:estimation_completed]

      continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

      if continue
        # Set Action (41) Job Estimation Done, DB.spt_act_job_estimate. Set supp_engr_user = supp_engr_user (Input variable)

        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(41).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_act_job_estimation(ticket_estimation_id: @ticket_estimation.id, supplier_id: @ticket_estimation_external.repair_by_id)

        user_ticket_action.save

        t_est_price = @ticket_estimation_external.approved_estimated_price.to_f + @ticket_estimation.ticket_estimation_additionals.sum(:approved_estimated_price).to_f
        if t_est_price > 0
          @ticket_estimation.update_attribute(:cust_approval_required, true)
        else
          @ticket_estimation.update_attribute(:cust_approval_required, false)
        end

        @ticket.update_attribute(:status_resolve_id, TicketStatusResolve.find_by_code("EST").id)# (Estimated).
        @ticket_estimation.update_attribute(:status_id, EstimationStatus.find_by_code("EST").id)#EST (Estimated).
        @ticket_estimation.update_attribute(:approved, true)

        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = {notice: "Successfully updated"}
        else
          @flash_message = {error: "ticket is updated. but Bpm error"}
        end
      end
    end
    redirect_to todos_url, notice: "Successfully updated."
  end

  def update_delivery_unit
    TicketSparePart

    @ticket_deliver_unit = TicketDeliverUnit.find params[:ticket_deliver_id]

    @ticket.attributes = ticket_params

    @ticket.ticket_deliver_units.select{|d| d.changed?}.each do |t_d_u|

      ticket_deliver_unit = t_d_u
      ticket_deliver_unit_note = ticket_deliver_unit.note_change.last

      if ticket_deliver_unit.delivered_to_sup_changed? and ticket_deliver_unit.delivered_to_sup

        @ticket_deliver_unit.update(delivered_to_sup_at: DateTime.now, delivered_to_sup_by: current_user.id)

        # Set Action (29) Delivered Unit To Supplier, DB.spt_act_deliver_unit
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(29).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_deliver_unit(ticket_deliver_unit_id: @ticket_deliver_unit.id, deliver_to_id: @ticket_deliver_unit.deliver_to_id, deliver_note: ticket_deliver_unit_note)

        user_ticket_action.save
      end

      
      if ticket_deliver_unit.collected
          continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

        if continue
          @ticket_deliver_unit.update(collected_at: DateTime.now, collected_by: current_user.id)

          #  Set Action (30) Collected Unit From Supplier, DB.spt_act_deliver_unit
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(30).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
          user_ticket_action.build_deliver_unit(ticket_deliver_unit_id: @ticket_deliver_unit.id, deliver_to_id: @ticket_deliver_unit.deliver_to_id, deliver_note: ticket_deliver_unit_note)

          user_ticket_action.save


          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"
            @flash_message = {notice: "Successfully updated"}
          else
            @flash_message = {error: "ticket is updated. but Bpm error"}
          end
        else
          @flash_message = "Bpm error. ticket is not updated"
        end
      end
      ticket_deliver_unit.note = "#{ticket_deliver_unit_note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket_deliver_unit.note}"
    end

    @ticket.save
    # latest_note = @ticket_deliver_unit.note
    # @ticket_deliver_unit.update(note: "#{ticket_deliver_unit_note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{latest_note}")
    redirect_to todos_url, notice: "Successfully updated."
  end

  def omp_update_hold
    
  end

  def load_serial_and_part
    Inventory

    if params[:inventory_type] == "serial_part"
      @inventory_type = InventorySerialPart.find params[:inventory_type_id]
    elsif params[:inventory_type] == "serial_item"
      @inventory_type = InventorySerialItem.find params[:inventory_type_id]

      # @inventory_serial_parts = @inventory_type.inventory_serial_parts
      @inventory_serial_parts = Kaminari.paginate_array(@inventory_type.inventory_serial_parts).page(params[:page]).per(10)
    end

  end

  private

    def find_ticket
      @ticket = Ticket.find params[:ticket_id]
    end

    def ticket_spare_part_params ticket_spare_part
      t_spare_part = params.require(:ticket_spare_part).permit(:spare_part_no, :spare_part_description, :ticket_id, :ticket_fsr, :cus_chargeable_part, :request_from, :faulty_serial_no, :faulty_ct_no, :note, :status_action_id, :part_terminated, :status_use_id, :part_terminated_reason_id, :received_spare_part_no, :received_part_serial_no, :received_part_ct_no, :repare_start, :repare_end, :return_part_serial_no, :return_part_ct_no, ticket_attributes: [:remarks, :id])
      t_spare_part[:note] = t_spare_part[:note].present? ? "#{t_spare_part[:note]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_spare_part.note}" : ticket_spare_part.note

      t_spare_part[:repare_start] = Time.strptime(t_spare_part[:repare_start],'%m/%d/%Y %I:%M %p') if t_spare_part[:repare_start].present?
      t_spare_part[:repare_end] = Time.strptime(t_spare_part[:repare_end],'%m/%d/%Y %I:%M %p') if t_spare_part[:repare_end].present?
      t_spare_part
    end

    def ticket_on_loan_spare_part_params ticket_onloan_spare_part
      t_onloan_spare_part = params.require(:ticket_on_loan_spare_part).permit(:return_part_serial_no, :return_part_ct_no, :unused_reason_id, :note, :part_terminated_reason_id, :approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :ref_spare_part_id, :note, :ticket_id, :status_action_id, :status_use_id, :store_id, :inv_product_id, :main_inv_product_id, :part_of_main_product, ticket_attributes: [:remarks, :id])

      t_onloan_spare_part[:note] = t_onloan_spare_part[:note].present? ? "#{t_onloan_spare_part[:note]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_onloan_spare_part.note}" : ticket_onloan_spare_part.note
      t_onloan_spare_part
    end

    def estimation_params
      params.require(:ticket_estimation).permit(:note, :id, :cust_approved, :cust_approved_by)
    end

    def ticket_params
      params.require(:ticket).permit(ticket_estimations_attributes: [:id, :advance_payment_amount, :note, :approved_adv_pmnt_amount, ticket_estimation_externals_attributes: [:id, :repair_by_id, :cost_price, :estimated_price, :warranty_period, :approved_estimated_price], ticket_estimation_additionals_attributes: [:ticket_id, :additional_charge_id, :cost_price, :estimated_price, :_destroy, :id, :approved_estimated_price]], ticket_deliver_units_attributes: [:id, :note, :collected, :delivered_to_sup])
    end
end