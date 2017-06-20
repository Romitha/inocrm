class InventoriesController < ApplicationController
  before_action :find_ticket, only: [:update_low_margin_estimate, :update_estimate_job, :update_delivery_unit]

  def inventory_in_modal
    Inventory
    Grn
    session[:select_frame] = params[:select_frame]
    if params[:select_inventory] and (params[:inventory_id] or params[:inventory_product_id] or params[:non_inventory_product_id]) and session[:select_frame]
      @inventory = Inventory.find params[:inventory_id] if params[:inventory_id]
      @inventory_product = InventoryProduct.find params[:inventory_product_id] if params[:inventory_product_id]
      @non_stock = InventoryProduct.find params[:non_inventory_product_id] if params[:non_inventory_product_id]

      if session[:select_frame] == "request_from"
        if @inventory
          session[:store_id] = @inventory.store_id
          session[:inv_product_id] = @inventory.product_id
        elsif @inventory_product
          session[:store_id] = session[:requested_store_id]
          session[:inv_product_id] = @inventory_product.id
        elsif @non_stock
          session[:store_id] = session[:requested_store_id]
          session[:inv_product_id] = @non_stock.id
        end

      elsif session[:select_frame] == "main_product"

        if @inventory
          session[:mst_store_id] = @inventory.store_id
          session[:mst_inv_product_id] = @inventory.product_id
        elsif @inventory_product
          session[:mst_store_id] = session[:requested_store_id]
          session[:mst_inv_product_id] = @inventory_product.id
        end

      end
      if params[:issue_part] == "true"
        approved_inventory_product = (@inventory_product || @inventory.inventory_product)
        # isi = approved_inventory_product.inventory_serial_items.joins(:inventory).where(inv_inventory: {store_id: session[:requested_store_id].to_i}, inv_status_id: InventorySerialItemStatus.find_by_code("AV").id)

        gsi = GrnSerialItem.includes(:inventory_serial_item).where(grn_item_id: approved_inventory_product.grn_items.select{|grn_item| grn_item.grn.store_id == session[:requested_store_id]}.map{|grn_item| grn_item.id}, remaining: 1)

        if approved_inventory_product.fifo
          # @main_part_serial = isi.select{|i| i.grn_items.present? }.sort{|p, n| p.grn_items.last.grn.created_at <=> n.grn_items.last.grn.created_at}
          @main_part_serial = gsi.sort{|p, n| p.grn_item.grn.created_at <=> n.grn_item.grn.created_at }
        else
          # @main_part_serial = isi.select{|i| i.grn_items.present? }.sort{|p, n| p.grn_items.last.grn.created_at <=> n.grn_items.last.grn.created_at}
          @main_part_serial = gsi.sort{|p, n| n.grn_item.grn.created_at <=> p.grn_item.grn.created_at }
        end
      end
    end
  end

  def hp_po
    Inventory
    TicketSparePart
    Product
    @create_so_po = SoPo.new
    @view_so_pos = SoPo.all
    # @ticket_spare_part = TicketSparePart.all.page(params[:page]).per(3)
    @ticket_spare_part = Kaminari.paginate_array(TicketSparePart.all).page(params[:page]).per(10)
    render "inventories/hp_po_or_sales_order"
  end

  def view_hp_po_sales_spare_parts_ajax
    po_id = params[:po_id]
    if po_id.present?
      @sopo = SoPo.find po_id
    else

    end
  end

  def paginate_hp_po_sales_order
    TicketSparePart
    @rendering_id = params[:rendering_id]
    @rendering_file = params[:rendering_file]
    @ticket_spare_part = TicketSparePart.all.page(params[:page]).per(params[:per_page])
  end

  def search_inventories
    Inventory
    respond_to do |format|
      category1_id = params[:search_inventory]["brand"]
      category2_id = params[:search_inventory]["product"]
      inventory_product_hash = params[:search_inventory].except("brand", "product").to_hash
      session[:requested_store_id] = inventory_product_hash["store_id"].to_i
      @display_results = true
      @store = Organization.find session[:requested_store_id]

      category = {mst_inv_category2: category2_id, mst_inv_category1: category1_id}.map { |k, v| "#{k}.id = #{v}" if v.present? }.compact.join(" and ")
      updated_hash = inventory_product_hash["mst_inv_product"].to_hash.map { |k, v| "#{k} like '%#{v}%'" if v.present? }.compact.join(" and ")
      updated_hash_for_inventory = inventory_product_hash["mst_inv_product"].to_hash.map { |k, v| "mst_inv_product.#{k} like '%#{v}%'" if v.present? }.compact.join(" and ")
      updated_hash = [updated_hash, category].map { |e| e if e.present? }.compact.join(" and ")
      updated_hash_for_inventory = [updated_hash_for_inventory, category].map { |e| e if e.present? }.compact.join(" and ")

      if params[:select_frame] == "main_product"
        @inventories = @store.inventories.joins(inventory_product: [:inventory_product_info, inventory_category3: {inventory_category2: :inventory_category1}]).where(mst_inv_product_info: {need_serial: true}).where(updated_hash_for_inventory).references(:mst_inv_product)

        @inventory_products = InventoryProduct.joins(:inventory_product_info, inventory_category3: {inventory_category2: :inventory_category1}).where(mst_inv_product_info: {need_serial: true}).where(updated_hash).to_a.keep_if {|p| !p.non_stock_item.present? and p.inventories.empty? }
        @non_stock_products = InventoryProduct.joins(:inventory_product_info, inventory_category3: {inventory_category2: :inventory_category1}).where(mst_inv_product_info: {need_serial: true}).where(updated_hash).to_a.keep_if {|p| p.non_stock_item.present? and p.inventories.empty? }

      else
        @inventories = @store.inventories.joins(inventory_product: [:inventory_product_info, inventory_category3: {inventory_category2: :inventory_category1}]).where(updated_hash_for_inventory).references(:mst_inv_product)
        @inventory_products = InventoryProduct.joins(:inventory_product_info, inventory_category3: {inventory_category2: :inventory_category1}).where(updated_hash).to_a.keep_if {|p| !p.non_stock_item.present? and p.inventories.empty? }
        @non_stock_products = InventoryProduct.joins(:inventory_product_info, inventory_category3: {inventory_category2: :inventory_category1}).where(updated_hash).to_a.keep_if {|p| p.non_stock_item.present? and p.inventories.empty? }

      end

      format.js {render :inventory_in_modal}
    end
  end

  def search_inventory_product
    Inventory
    @store = Organization.find params[:store_id] if params[:store_id].present?
    @remote = params[:remote].to_bool if params[:remote].present?
    @display_method = {}
    @select_path = params[:select_path] if params[:select_path].present?
    if params[:select_options].present?
      @select_options = Hash[params[:select_options].strip.split("<>").map { |e| e.strip.split(":") }]
      session[:select_options] = @select_options
    end

    if params[:modal_id].present?
      @display_method.merge! modal: {modal_id: params[:modal_id]}
    elsif params[:render_id].present?
      @display_method.merge! inpage: {render_id: params[:render_id]}
    end
    @select_options = session[:select_options]

    store_id = params[:store_id]
    if params[:search].present?
      refined_inventory_product = params[:search_inventory][:inventory_product].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      # refined_inventory_serial_items = params[:search_inventory].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

      # refined_search = [refined_inventory_product, (store_id.present? ? "stores.id:#{store_id}" : "_exists_:stores")].map{|v| v if v.present? }.compact.join(" AND ")

      refined_search = [refined_inventory_product, ("stores.id:#{store_id}" if store_id.present? ), ("product_type:Serial" if params[:from_where] == "part_of_main_unit")].map{|v| v if v.present? }.compact.join(" AND ")

      params[:query] = refined_search

      ag = InventoryProduct.advance_search(params)

      # @total_stock_cost = ag.aggregations.stock_cost.value
      @total_stock_cost = ag.hits.hits.map{|h| h["_source"]["inventories"].sum{|i| i["store_id"] == store_id.to_i ? i["product_stock_cost"] : 0}}.sum
    end
    @inventory_products = InventoryProduct.search(params)

    render "inventories/inventory_products/select_product"
  end

  def update_part_order

    ticket_spare_part = TicketSparePart.find params[:ticket_spare_part_id]
    @ticket = ticket_spare_part.ticket
    engineer_id = params[:engineer_id]

    ticket_spare_part.update(ticket_spare_part_params(ticket_spare_part))

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    same_page = todos_url
    goto_url = todos_url

    save_ticket_spare_part = Proc.new do |spare_part_status, action_id_no|
      ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code(spare_part_status).id

      ticket_spare_part.ticket_spare_part_status_actions.create(status_id: ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

      action_id = TaskAction.find_by_action_no(action_id_no).id
      user_ticket_action = ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_spare_part.ticket.re_open_count, action_id: action_id, action_engineer_id: engineer_id)

      user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part.id, inv_srr_id: ticket_spare_part.try(:ticket_spare_part_store).try(:inv_srr_id), inv_srr_item_id: ticket_spare_part.try(:ticket_spare_part_store).try(:inv_srr_item_id))

      user_ticket_action.save
      ticket_spare_part.ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if ticket_spare_part.ticket.ticket_status.code == "ASN"
    end

    manufacture_warranty = (ticket_spare_part.ticket_spare_part_manufacture and not ticket_spare_part.cus_chargeable_part)
    manufacture_chargeable = (ticket_spare_part.ticket_spare_part_manufacture and ticket_spare_part.cus_chargeable_part)
    store_warranty = (ticket_spare_part.ticket_spare_part_store and not ticket_spare_part.cus_chargeable_part)
    store_chargeable = (ticket_spare_part.ticket_spare_part_store and ticket_spare_part.cus_chargeable_part)
    non_stock_warranty = (ticket_spare_part.ticket_spare_part_non_stock and not ticket_spare_part.cus_chargeable_part)
    non_stock_chargeable = (ticket_spare_part.ticket_spare_part_non_stock and ticket_spare_part.cus_chargeable_part)    

    rce = ticket_spare_part.spare_part_status_action.code == "RCE" # Received by Engineer
    rpr = ticket_spare_part.spare_part_status_action.code == "RPR" # Returned Part Reject
    rqt = ticket_spare_part.spare_part_status_action.code == "RQT" # Requested
    str = ticket_spare_part.spare_part_status_action.code == "STR" # Request from Store
    ecm = ticket_spare_part.spare_part_status_action.code == "ECM" # Estimation Completed
    cea = ticket_spare_part.spare_part_status_action.code == "CEA" # Cus. Estimation Approved
    iss = ticket_spare_part.spare_part_status_action.code == "ISS" # Issued
    mpr = ticket_spare_part.spare_part_status_action.code == "MPR" #Manufacture Part Requested

    # bpm output variables
    ticket_id = @ticket.id
    request_spare_part_id = ticket_spare_part.id
    supp_engr_user = current_user.id
    priority = @ticket.priority
    request_onloan_spare_part_id = '-'
    onloan_request = "N"

    # bpm output variables
    bpm_variables = view_context.initialize_bpm_variables
    process_name = ""
    
    if params[:terminate]
      if (manufacture_warranty and mpr) or (manufacture_chargeable and (rqt or ecm or cea)) or (store_warranty and str) or (store_chargeable and (rqt or ecm or cea)) or (non_stock_warranty and rqt) or (non_stock_chargeable and (rqt or ecm or cea)) 

        save_ticket_spare_part["CLS", 19] #Terminate Spare Part

        if (ticket_spare_part.ticket_spare_part_manufacture)
          ticket_spare_part.ticket_spare_part_manufacture.update po_required: false
        end

        flash[:notice] = "Termination is successfully done."
        goto_url = same_page
      end
    
    elsif params[:return]

      if not params[:update_without_return]
        if continue
          if (manufacture_warranty or manufacture_chargeable) and (rce or rpr)

            ticket_spare_part.update_attributes(
              part_returned: true,
              part_returned_at: DateTime.now,
              part_returned_by: current_user.id,
            )

            save_ticket_spare_part["RTN", 17] #Return Part (Spare/Faulty)

            # bpm output variables
            bpm_variables.merge!(d32_return_manufacture_part: "Y")

            # Create Process "SPPT_MFR_PART_RETURN",
            process_name = "SPPT_MFR_PART_RETURN"
            query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}

          elsif (store_warranty and (rce or rpr)) or (store_chargeable and (rce or rpr))

            srr = Srr.create(
              store_id: ticket_spare_part.ticket_spare_part_store.srn.store_id,
              requested_location_id: ticket_spare_part.ticket_spare_part_store.srn.requested_location_id,
              srr_no: CompanyConfig.first.increase_inv_last_srr_no,
              requested_module_id: ticket_spare_part.ticket_spare_part_store.srn.requested_module_id,
              created_by: current_user.id,
              created_at:  DateTime.now
              )

            srr_item = srr.srr_items.create(
              product_id: ticket_spare_part.ticket_spare_part_store.srn_item.product_id,
              quantity: ticket_spare_part.ticket_spare_part_store.srn_item.quantity,
              #product_condition_id
              #return_reason_id
              returnable_srn_item_id: ticket_spare_part.ticket_spare_part_store.srn_item.id,
              spare_part: ticket_spare_part.ticket_spare_part_store.srn_item.spare_part,
              currency_id: ticket_spare_part.ticket_spare_part_store.gin_item.currency_id
            )

            srr_item_source = srr_item.srr_item_sources.create(
              gin_source_id: ticket_spare_part.ticket_spare_part_store.gin_item.gin_sources.first.id,
              returned_quantity: ticket_spare_part.ticket_spare_part_store.gin_item.gin_sources.first.issued_quantity,
              unit_cost: ticket_spare_part.ticket_spare_part_store.gin_item.gin_sources.first.unit_cost,
              currency_id: ticket_spare_part.ticket_spare_part_store.gin_item.currency_id
            )

            ticket_spare_part.update_attributes(
              part_returned: true,
              part_returned_at: DateTime.now,
              part_returned_by: current_user.id,
            )
            
            ticket_spare_part.ticket_spare_part_store.update_attributes(
              inv_srr_id: srr.id,
              inv_srr_item_id: srr_item.id,
              returned_quantity: ticket_spare_part.ticket_spare_part_store.approved_quantity
            )

            save_ticket_spare_part["RTN", 17] #Return Part (Spare/Faulty)

            # bpm output variables
            bpm_variables.merge!(d24_return_store_part: "Y")

            # Create Process "SPPT_STORE_PART_RETURN",
            process_name = "SPPT_STORE_PART_RETURN"
            query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority}

          end

        end
      else
        flash[:error] = "spare part is updated. But not returned"
      end

    elsif params[:store_request]

      if continue
        if store_chargeable and cea

          ticket_spare_part.ticket_spare_part_store.update store_requested: true, store_requested_at: DateTime.now, store_requested_by: current_user.id

          save_ticket_spare_part["STR", 15] #Request Spare Part from Store 

          # bpm output variables
          bpm_variables.merge!(d17_request_store_part: "Y")

          # Create Process "SPPT_STORE_PART_REQUEST",
          process_name = "SPPT_STORE_PART_REQUEST"
          query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority}

        end

      else
        flash[:error] = "Bpm error. ticket is not updated"
      end    

    elsif params[:recieved]
      if iss and (manufacture_warranty or manufacture_chargeable or store_warranty or store_chargeable)
        save_ticket_spare_part["RCE", 16] #Receive Spare Part by eng
        ticket_spare_part.update received_eng: true
        goto_url = same_page
      end

    elsif params[:manufacture_request]
      if continue
        if manufacture_chargeable and cea

          save_ticket_spare_part["MPR", 14] #Request Spare Part from Manufacture

          # bpm output variables
          bpm_variables.merge!(d16_request_manufacture_part: "Y")

          process_name = "SPPT_MFR_PART_REQUEST"
          query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}
        end

      else
        flash[:error] = "Bpm error. ticket is not updated"
      end    

    elsif params[:non_stock_complete]
      if (non_stock_warranty and rqt) or (non_stock_chargeable and cea) 

        save_ticket_spare_part["CLS", 79] 

        flash[:notice] = "successfully completed."
        goto_url = same_page
      end

    end

    if continue
      bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if process_name.present?
        bpm_response1 = view_context.send_request_process_data start_process: true, process_name: process_name, query: query

        if bpm_response1[:status].try(:upcase) == "SUCCESS"
          @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
          view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id, request_spare_part_id
        else
          @bpm_process_error = true
        end
      end

      if bpm_response[:status].upcase == "SUCCESS"
        flash[:notice] = "Successfully updated."
      else
        flash[:error] = "spare part is updated. but Bpm error"
      end
      
      flash[:error] = "#{@flash_message} Unable to start new process." if @bpm_process_error
    end

    redirect_to goto_url
  end

  def update_onloan_part_order
    ticket_on_loan_spare_part = TicketOnLoanSparePart.find params[:ticket_on_loan_spare_part_id]
    @ticket = ticket_on_loan_spare_part.ticket

    ticket_on_loan_spare_part.update ticket_on_loan_spare_part_params(ticket_on_loan_spare_part) 

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    engineer_id = params[:engineer_id]

    save_ticket_on_loan_spare_part = Proc.new do |onloan_spare_part_status, action_id_no|

      ticket_on_loan_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code(onloan_spare_part_status).id

      ticket_on_loan_spare_part.ticket_on_loan_spare_part_status_actions.create(status_id: ticket_on_loan_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

      action_id = TaskAction.find_by_action_no(action_id_no).id
      user_ticket_action = @ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_id: action_id, action_engineer_id: engineer_id)

      user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: ticket_on_loan_spare_part.id, inv_srr_id: ticket_on_loan_spare_part.inv_srr_id, inv_srr_item_id: ticket_on_loan_spare_part.inv_srr_item_id)

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
        save_ticket_on_loan_spare_part["CLS", 53] #Terminate On-Loan Part
        @flash_message = "Terminate action is Successfully done."
      end
    
    elsif params[:return]
      if not params[:update_without_return]
        if continue
          if rce or rpr

            srr = Srr.create(
              store_id: ticket_on_loan_spare_part.srn.store_id,
              requested_location_id: ticket_on_loan_spare_part.srn.requested_location_id,
              srr_no: CompanyConfig.first.increase_inv_last_srr_no,
              requested_module_id: ticket_on_loan_spare_part.srn.requested_module_id,
              created_by: current_user.id,
              created_at:  DateTime.now
              )

            srr_item = srr.srr_items.create(
              product_id: ticket_on_loan_spare_part.srn_item.product_id,
              quantity: ticket_on_loan_spare_part.srn_item.quantity,
              #product_condition_id
              #return_reason_id
              returnable_srn_item_id: ticket_on_loan_spare_part.srn_item.id,
              spare_part: ticket_on_loan_spare_part.srn_item.spare_part
            )

            srr_item_source = srr_item.srr_item_sources.create(
              gin_source_id: ticket_on_loan_spare_part.gin_item.gin_sources.first.id,
              returned_quantity: ticket_on_loan_spare_part.gin_item.gin_sources.first.issued_quantity,
              unit_cost: ticket_on_loan_spare_part.gin_item.gin_sources.first.unit_cost,
              currency_id: ticket_on_loan_spare_part.gin_item.currency_id
            )

            ticket_on_loan_spare_part.update_attributes(
              part_returned: true,
              part_returned_at: DateTime.now,
              part_returned_by: current_user.id,
              inv_srr_id: srr.id,
              inv_srr_item_id: srr_item.id
            )

            save_ticket_on_loan_spare_part["RTN", 52] #Return On-Loan part

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
            bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_RETURN", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority}

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
      else
        @flash_message = "Bpm error. ticket is not updated"
      end


    elsif params[:recieved]

      if iss
        save_ticket_on_loan_spare_part["RCE", 51] #Receive On-Loan Part by eng
        @flash_message = "Recieve action is Successfully done."
      end
    end
    redirect_to todos_url, notice: @flash_message
  end

  def load_estimation
    Tax
    Invoice

    if params[:estimation_id].present?
      @estimation_type = params[:estimation_type]
      @estimation = TicketEstimation.find params[:estimation_id]

    elsif params[:quotation_id].present?
      @quotation = CustomerQuotation.find params[:quotation_id]

    end
  end

  def load_estimation_ticket_info
    @estimation_type = params[:estimation_type]
    @estimation = TicketEstimation.find params[:estimation_id]
  end

  def update_estimation_part_customer_approval
    Ticket
    Invoice
    status_action_id = SparePartStatusAction.find_by_code("CLS").id
    po_required = false

    request_spare_part = params[:request_spare_part].present?

    @estimation = TicketEstimation.find estimation_params[:id]
    updatable_estimation_params = estimation_params
    @estimation.attributes = updatable_estimation_params

    updatable_estimation_params.merge!(status_id: EstimationStatus.find_by_code("CLS").id, cust_approved_at: DateTime.now, cust_approved_by: current_user.id)
    @ticket = @estimation.ticket
    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    engineer_id = params[:engineer_id]

    if continue
      if @estimation.cust_approved

        if (@estimation.cust_approval_required)
          @estimation.ticket.update cus_payment_required: true
        end


        if ( !@estimation.approval_required and @estimation.advance_payment_amount.to_f > 0) or ( @estimation.approval_required and @estimation.approved_adv_pmnt_amount.to_f > 0)
          updatable_estimation_params.merge!(status_id: EstimationStatus.find_by_code("APP").id )

          quotation = @estimation.customer_quotations.find_by_canceled(false)
          d20_advance_payment_required = 'Y'
          if quotation
            d20_advance_payment_required =  quotation.advance_payment_requested ? 'N' : 'Y'
            quotation.update advance_payment_requested: true

          end
          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d20_advance_payment_required: d20_advance_payment_required, advance_payment_estimation_id: (quotation.try(:id) or '-'))

          @estimation.ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @estimation.ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"
            flash[:notice] = "Successfully updated"
          else
            flash[:error] = "ticket is updated. but Bpm error"
          end
        end
        status_action_id = SparePartStatusAction.find_by_code("CEA").id
        po_required = CompanyConfig.first.sup_mf_parts_po_requied

      end
      @estimation.ticket_estimation_parts.each do |ticket_estimation_part|
        ticket_estimation_part.ticket_spare_part.update_attributes(status_action_id: status_action_id, approved_estimation_part_id: ticket_estimation_part.id)

        ticket_estimation_part.ticket_spare_part.ticket_spare_part_manufacture.update po_required: po_required if ticket_estimation_part.ticket_spare_part.ticket_spare_part_manufacture.present?

        ticket_estimation_part.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: status_action_id, done_by: current_user.id, done_at: DateTime.now)

      end

      @estimation.attributes = updatable_estimation_params

      if @estimation.save
        # 76 - Part Estimation Customer Aproved
        user_ticket_action = @estimation.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(76).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @estimation.ticket.re_open_count, action_engineer_id: engineer_id)
        user_ticket_action.build_act_job_estimation(ticket_estimation_id: @estimation.id)

        user_ticket_action.save

        flash[:notice] = "Successfully updated"

      else
        flash[:error] = "Sorry! unable to update"

      end
      if request_spare_part
        @estimation.ticket_estimation_parts.each do |ticket_estimation_part|
          action_id = ''

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables
          request_spare_part_id = ticket_estimation_part.ticket_spare_part.id
          supp_engr_user = current_user.id
          priority = @estimation.ticket.priority
          ticket_id = @ticket.id

          if ticket_estimation_part.ticket_spare_part.ticket_spare_part_manufacture.present?
            #save_ticket_spare_part["MPR", 14] #Request Spare Part from Manufacture
            status_action_id = SparePartStatusAction.find_by_code("MPR").id
            action_id = TaskAction.find_by_action_no(14).id

            bpm_variables.merge!(d16_request_manufacture_part: "Y")

            process_name = "SPPT_MFR_PART_REQUEST"
            query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}
          end

          if ticket_estimation_part.ticket_spare_part.ticket_spare_part_store.present?
            ticket_estimation_part.ticket_spare_part.ticket_spare_part_store.update store_requested: true, store_requested_at: DateTime.now, store_requested_by: current_user.id

            #save_ticket_spare_part["STR", 15] #Request Spare Part from Store 
            status_action_id = SparePartStatusAction.find_by_code("STR").id
            action_id = TaskAction.find_by_action_no(15).id

            bpm_variables.merge!(d17_request_store_part: "Y")
            request_onloan_spare_part_id = '-'
            onloan_request = 'N'

            # Create Process "SPPT_STORE_PART_REQUEST",
            process_name = "SPPT_STORE_PART_REQUEST"
            query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority}
                
          end

          if action_id.present?
            ticket_estimation_part.ticket_spare_part.update_attributes(status_action_id: status_action_id, approved_estimation_part_id: ticket_estimation_part.id)

            ticket_estimation_part.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: status_action_id, done_by: current_user.id, done_at: DateTime.now)

            #Request Spare Part from Store
            user_ticket_action = @estimation.ticket.user_ticket_actions.build(action_id: action_id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @estimation.ticket.re_open_count, action_engineer_id: engineer_id)
            user_ticket_action.build_act_job_estimation(ticket_estimation_id: @estimation.id)

            user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_estimation_part.ticket_spare_part.id)

            user_ticket_action.save

          end

          if process_name
            bpm_response1 = view_context.send_request_process_data start_process: true, process_name: process_name, query: query

            if bpm_response1[:status].try(:upcase) == "SUCCESS"
              @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
              view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id, request_spare_part_id
              flash[:notice] = "Successfully part requested"
            else
              flash[:error] = "Sorry! unable to requeted the part"
            end
          end

        end
      end
    end
    redirect_to todos_url

  end

  def update_estimation_external_customer_approval
    Ticket

    @estimation = TicketEstimation.find estimation_params[:id]
    updatable_estimation_params = estimation_params
    request_deliver_unit = params[:request_deliver_unit].present?
    updatable_estimation_params.merge!( status_id: EstimationStatus.find_by_code("CLS").id, cust_approved_at: DateTime.now, cust_approved_by: current_user.id )

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    engineer_id = params[:engineer_id]
    # bpm output variables
    bpm_variables = view_context.initialize_bpm_variables
    @estimation.attributes = updatable_estimation_params
    if continue
      if @estimation.cust_approved

        if (@estimation.cust_approval_required)
          @estimation.ticket.update cus_payment_required: true
        end

        if ( !@estimation.approval_required and @estimation.advance_payment_amount.to_f > 0) or ( @estimation.approval_required and @estimation.approved_adv_pmnt_amount.to_f > 0)

          @estimation.status_id = EstimationStatus.find_by_code("APP").id

          quotation = @estimation.customer_quotations.where(canceled: false).first

          d20_advance_payment_required = 'Y'
          if quotation
            d20_advance_payment_required =  quotation.advance_payment_requested ? 'N' : 'Y'
            quotation.update advance_payment_requested: true
          end

          # bpm output variables
          bpm_variables.merge!(d20_advance_payment_required: d20_advance_payment_required, advance_payment_estimation_id: (quotation.try(:id) or '-'))
          bpm_do = true

        end

        if request_deliver_unit

          @ticket_deliver_unit = @estimation.ticket.ticket_deliver_units.build deliver_to_id: @estimation.ticket_estimation_externals.first.try(:repair_by_id), created_at: DateTime.now, created_by: current_user.id
          @ticket_deliver_unit.save

          # bpm output variables
          bpm_variables.merge!(supp_engr_user: current_user.id, d22_deliver_unit: "Y", deliver_unit_id: @ticket_deliver_unit.id, d23_delivery_items_pending: "N")
          # bpm_do = true
        end

        @estimation.ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @estimation.ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = {notice: "Successfully updated with bpm."}
        else
          @flash_message = {error: "estimation is updated. but Bpm error"}
        end
      end

      @estimation.attributes = updatable_estimation_params
      if @estimation.save

        user_ticket_action = @estimation.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(24).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @estimation.ticket.re_open_count, action_engineer_id: engineer_id)
        user_ticket_action.build_act_job_estimation(supplier_id: @estimation.ticket_estimation_externals.first.try(:organization).try(:id), ticket_estimation_id: @estimation.id)
        user_ticket_action.save

        if request_deliver_unit    
          #Deliver Unit
          user_ticket_action = @estimation.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(22).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @estimation.ticket.re_open_count, action_engineer_id: engineer_id)
          user_ticket_action.build_deliver_unit(ticket_deliver_unit_id: @ticket_deliver_unit.id)
          user_ticket_action.save
        end

        @flash_message = {notice: "Successfully updated"}
      else

        @flash_message = {error: "Sorry! unable to update"}
      end
    else
      @flash_message = {error: "Bpm error. ticket is not updated"}
    end
    redirect_to todos_url, @flash_message
  end

  def update_estimate_job

    Ticket
    Organization
    TaskAction
    @ticket_estimation = TicketEstimation.find params[:ticket_estimation_id]
    @ticket_estimation_external = TicketEstimationExternal.find params[:ticket_estimation_external_id]

    @ticket.update(ticket_params)

    @ticket_estimation.update_attributes(estimated_at: DateTime.now, estimated_by: current_user.id)
    @ticket_estimation_external.reload
    @ticket_estimation.reload

    if params[:estimation_completed].present?

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
    @ticket_estimation_external.reload
    @ticket_estimation.reload

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
      ticket_deliver_unit_note = ticket_deliver_unit.note_change

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
    end

    @ticket.save
    redirect_to todos_url, notice: "Successfully updated."
  end

  def update_return_store_part
    Srn
    Inventory
    Srr
    Gin
    Grn

    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    @onloan_request = params[:onloan_request] == "Y" ? true : false
    params[:damage_reason_check]
    params[:damage_reason]

    @add_rec = false

    if params[:inventory_serial_part].present? # Inventory Serial Part Returned
      @main_inventory_serial_part = InventorySerialItem.find session[:serial_part_item_id]
      @main_inventory_serial_part.update inventory_serial_item_params
      if params[:inventory_serial_part_or_item_id].present?
        @inventory_serial_part = InventorySerialPart.find params[:inventory_serial_part_or_item_id]
        # @inventory_serial_part.update inventory_serial_part_params
      else
        @inventory_serial_part = InventorySerialPart.new inventory_serial_part_params
        # @prev_inventory_serial_part = InventorySerialPart.find session[:serial_part_id]
        @add_rec = true
      end


    elsif params[:inventory_serial_item].present? # Inventory Serial Item Returned
      if params[:inventory_serial_part_or_item_id].present?
        @inventory_serial_item = InventorySerialItem.find params[:inventory_serial_part_or_item_id]
        # @inventory_serial_item.update inventory_serial_item_params
      else
        @inventory_serial_item = InventorySerialItem.new inventory_serial_item_params
        # @prev_inventory_serial_item = InventorySerialItem.find session[:serial_item_id]
        @add_rec = true
      end

    elsif params[:inventory_batch].present? # Inventory Batch Item Returned
      if params[:inventory_batch_id].present?
        @inventory_batch = InventoryBatch.find params[:inventory_batch_id]
        # @inventory_batch.update inventory_batch_params
      else
        @inventory_batch = InventoryBatch.new inventory_batch_params
        # @prev_grn_batch = InventoryBatch.find session[:grn_batch_id]
        @add_rec = true
      end

    elsif params[:grn_item].present? # Inventory Item Returned (Not Serial Part, Serial Item or Inventory Batch Item)
      if params[:grn_item_id].present?
        @grn_item = GrnItem.find params[:grn_item_id]
        @grn_item.update grn_item_params
      else
        @grn_item = GrnItem.new grn_item_params
        # @prev_grn_item = GrnItem.find session[:grn_item_id]
        @add_rec = true
      end
    end

    if @onloan_request
      @onloan_request_part = TicketOnLoanSparePart.find params[:request_onloan_spare_part_id]

      @onloan_request_part.update(note: params[:note])

      @allready_received = @onloan_request_part.ret_part_received
    else
      @ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]

      @ticket_spare_part.update(note: params[:note])

      @allready_received = @ticket_spare_part.returned_part_accepted
    end

    if continue
      if @allready_received
      flash[:error] = "Part allready returned."
      else

        if params[:reject_reason] # Reject the request
          # 42 Reject Returned Part
          action_id = TaskAction.find_by_action_no(42).id

          @updating_part_params = {part_returned: false, part_returned_at: nil, part_returned_by: nil, return_part_serial_no: nil, return_part_ct_no: nil, status_action_id: SparePartStatusAction.find_by_code("RPR").id}

          @inv_srr_params = {inv_srr_id: nil, inv_srr_item_id: nil}

          if @onloan_request
            @updating_part = @onloan_request_part

            # inv_srr - edit
            @inv_srr = @updating_part.srr
            # inv_srr_item - edit
            @inv_srr_item = @updating_part.srr_item

            @updating_part.update @updating_part_params.merge(@inv_srr_params)

            @updating_part.ticket_on_loan_spare_part_status_actions.create(status_id: @updating_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

            user_ticket_action = @updating_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @updating_part.ticket.re_open_count, action_id: action_id)
            user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: @updating_part.id)

          else #Store Request (not On-Loan)
            @updating_part = @ticket_spare_part.ticket_spare_part_store

            # inv_srr - edit
            @inv_srr = @updating_part.srr
            # inv_srr_item - edit
            @inv_srr_item = @updating_part.srr_item

            @updating_part.ticket_spare_part.update @updating_part_params

            @updating_part.update @inv_srr_params

            # @updating_part = @ticket_spare_part

            @updating_part.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @updating_part.ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

            user_ticket_action = @updating_part.ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @updating_part.ticket_spare_part.ticket.re_open_count, action_id: action_id)
            user_ticket_action.build_request_spare_part(ticket_spare_part_id: @updating_part.ticket_spare_part.id)

          end

          @inv_srr.update closed: true
          @inv_srr_item.update closed: true

          user_ticket_action.save

          bpm_variables = view_context.initialize_bpm_variables

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. but Bpm error"
          end

        else

          @returned = false
          if @onloan_request
            @updating_part = @onloan_request_part
          else
            @updating_part = @ticket_spare_part.ticket_spare_part_store
          end 
          @inv_srn_item = @updating_part.srn_item
          @inv_srr = @updating_part.srr  
          @inv_srr_item = @updating_part.srr_item

          @inv_gin_source =  @inv_srr_item.gin_sources.first 

          if @inventory_serial_part.present? and @inv_srr_item.quantity == 1 # Inventory Serial Part Returned

            @inventory_serial_part_attributes = inventory_serial_part_params
            @inv_grn_item_attributes = {}

            if @add_rec # Add new record (Part)
              @inv_grn_item_attributes.merge!(grn_item_params)
              # inv_inventory_serial_part - Add

              # inv_warranty - Add
              # inv_serial_part_warranty - Add    
              if params[:warranty_check]
                @inv_warranty = InventoryWarranty.new inventory_warranty_params
                @inv_warranty.created_by = current_user.id
                @inv_warranty.save

                @inventory_serial_part.inventory_warranties << @inv_warranty
              end

              @inventory_serial_part_attributes.merge!(serial_item_id: @main_inventory_serial_part.id)

              @inventory_serial_part_attributes.merge!(product_id: @inv_gin_source.grn_serial_part.inventory_serial_part.product_id) if !@inventory_serial_part_attributes[:product_id].present?

            else # update record (Part)
              # inv_inventory_serial_part - Edit

              #new grn cost similar to last grn cost 
              @inv_grn_item_attributes.merge!(unit_cost: @inv_gin_source.grn_serial_part.grn_item.unit_cost, currency_id: @inv_gin_source.grn_serial_part.grn_item.currency.id)

            end

            # inv_inventory_serial_part - save
            if @onloan_request
              @inventory_serial_part_attributes.merge!(serial_no: @onloan_request_part.return_part_serial_no, ct_no: @onloan_request_part.return_part_ct_no)
            else
              @inventory_serial_part_attributes.merge!(serial_no: @ticket_spare_part.return_part_serial_no, ct_no: @ticket_spare_part.return_part_ct_no)
            end
            @inventory_serial_part_attributes.merge!(created_by: current_user.id, updated_by: current_user.id, damage: params[:damage_reason_check].present?)
            @inventory_serial_part.attributes = @inventory_serial_part_attributes
            @inventory_serial_part.save

            # inv_inventory_serial_item - edit
            @main_inventory_serial_part.update damage: params[:main_part_damage_reason_check].present?

            # inv_grn - add
            @inv_grn = Grn.new store_id: @inv_srr.store.id, grn_no: CompanyConfig.first.increase_inv_last_grn_no, srr_id: @inv_srr.id, created_by: current_user.id

            # inv_grn_item - add
            @inv_grn_item = @inv_grn.grn_items.build(@inv_grn_item_attributes)

            @inv_grn_item_attributes.merge!({
              product_id:  @inventory_serial_part.product_id,
              recieved_quantity: 1,
              remaining_quantity: 1,
              reserved_quantity: 0,
              damage_quantity: (params[:damage_reason_check].present? ? 1 : 0),
              current_unit_cost: @inv_grn_item.unit_cost,
              srr_item_id: @inv_srr_item.id,
              inventory_not_updated: true,
              main_product_id: @main_inventory_serial_part.product_id
            })

            @inv_grn_item.attributes = @inv_grn_item_attributes

            # inv_grn_serial_part - Add
            @inv_grn_part = @inv_grn_item.grn_serial_parts.build
            @inv_grn_part.serial_item_id = @main_inventory_serial_part.id
            @inv_grn_part.inv_serial_part_id = @inventory_serial_part.id
            @inv_grn_part.remaining = 1

            @inv_grn.save

            @inv_grn_item.grn_item_current_unit_cost_histories.create created_by: current_user.id, current_unit_cost: @inv_grn_item.current_unit_cost

            #inv_inventory Edit
            #Inventory not updated

            # inv_damage - Add For Part
            if params[:damage_reason_check].present?
              @inv_damage1 = Damage.new({
                store_id: @inv_srr.store.id,
                product_id: @inventory_serial_part.product_id,
                grn_item_id: @inv_grn_item.id,
                grn_batch_id: nil,
                grn_serial_item_id: nil,
                grn_serial_part_id: @inv_grn_part.id,
                spare_part: true,
                quantity: 1,
                unit_cost: @inv_grn_item.unit_cost,
                currency_id: @inv_grn_item.currency.id,
                srr_item_id: @inv_srr_item.id,
                product_condition_id: @inventory_serial_part.product_condition.id,
                damage_reason_id: params[:damage_reason],
                repair_quantity: 0,
                spare_quantity: 0,
                disposal_quantity: 0,
                disposed_quantity: 0
              })
              @inv_damage1.save
            end

            # inv_damage - Add for Main Item
            if params[:main_part_damage_reason_check].present?
              @inv_damage2 = Damage.new({
                store_id: @inv_srr.store.id,
                product_id: @main_inventory_serial_part.product_id,
                grn_item_id: @inv_gin_source.main_part_grn_serial_item.grn_item.id,
                grn_batch_id: nil,
                grn_serial_item_id: @inv_gin_source.main_part_grn_serial_item.id,
                grn_serial_part_id: nil,
                spare_part: true,
                quantity: 1,
                unit_cost: @inv_gin_source.main_part_grn_serial_item.grn_item.unit_cost,
                currency_id: @inv_gin_source.main_part_grn_serial_item.grn_item.currency_id,
                srr_item_id: @inv_srr_item.id,
                product_condition_id: @main_inventory_serial_part.product_condition.id,
                damage_reason_id: params[:main_part_damage_reason],
                repair_quantity: 0,
                spare_quantity: 0,
                disposal_quantity: 0,
                disposed_quantity: 0
              })

              @inv_damage2.save
            end

            # inv_gin_item - edit
            @inv_gin_source.gin_item.update returned_quantity: (@inv_gin_source.gin_item.returned_quantity.to_i + 1), return_completed: (@inv_gin_source.gin_item.returnable && (@inv_gin_source.gin_item.issued_quantity.to_i == (@inv_gin_source.gin_item.returned_quantity.to_i + 1)))

            # inv_gin_source - edit
            @inv_gin_source.update returned_quantity: (@inv_gin_source.returned_quantity.to_i + 1)

            # inv_srn_item - edit
            @inv_srn_item.update closed: true, return_completed: (@inv_srn_item.returnable)

            # inv_srr - edit
            @inv_srr.update closed: true

            # inv_srr_item - edit
            @inv_srr_item.update closed: true

            @returned = true

          elsif @inventory_serial_item.present? # Inventory Serial Item Returned

            @inventory_serial_item_attributes = inventory_serial_item_params
            @inv_grn_item_attributes = {}

            if @add_rec # Add new record (Item)
 
              @inv_grn_item_attributes.merge! grn_item_params
              # inv_warranty - Add
              # inv_serial_warranty - Add  
              if params[:warranty_check]
                @inv_warranty = InventoryWarranty.new inventory_warranty_params
                @inv_warranty.created_by = current_user.id
                @inv_warranty.save
                @inventory_serial_item.inventory_warranties << @inv_warranty
              end

              # inv_inventory_serial_item - Add
              @inventory_serial_item_attributes.merge!(product_id: @inv_gin_source.grn_serial_item.inventory_serial_item.product_id) if !@inventory_serial_item_attributes[:product_id].present?

              @inventory_serial_item_attributes.merge! inventory_id: Inventory.where(product_id: @inventory_serial_item_attributes[:product_id], store_id: @inv_srr.store.id).first.id

              if @onloan_request
                @inventory_serial_item_attributes.merge! serial_no: @onloan_request_part.return_part_serial_no, ct_no: @onloan_request_part.return_part_ct_no
              else
                @inventory_serial_item_attributes.merge! serial_no: @ticket_spare_part.return_part_serial_no, ct_no: @ticket_spare_part.return_part_ct_no             
              end

              @inventory_serial_item_attributes.merge! created_by: current_user.id

              # inv_inventory_batch - Add
              if params[:grn_batch_check]
                @inv_batch = InventoryBatch.new inventory_batch_params
                @inv_batch.inventory_id = @inventory_serial_item_attributes[:inventory_id] #@inventory_serial_item.inventory_id
                @inv_batch.product_id = @inventory_serial_item_attributes[:product_id] #@inventory_serial_item.product_id
                @inv_batch.created_by = current_user.id
                @inv_batch.save

              end
            else # update record (Item)
              # inv_inventory_serial_item - Edit

              #new grn cost similar to last grn cost 
              @inv_grn_item_attributes.merge!(unit_cost: @inv_gin_source.grn_serial_item.grn_item.unit_cost, currency_id: @inv_gin_source.grn_serial_item.grn_item.currency_id)

            end

            @inventory_serial_item_attributes.merge! damage: params[:damage_reason_check].present?, updated_by: current_user.id
            @inventory_serial_item.attributes = @inventory_serial_item_attributes
            @inventory_serial_item.save
            @inventory_serial_item.update(batch_id: @inv_batch.id) if @inv_batch.present?

            # inv_grn - add
            @inv_grn = Grn.new store_id: @inv_srr.store.id, grn_no: CompanyConfig.first.increase_inv_last_grn_no, srr_id: @inv_srr.id, created_by: current_user.id

            # inv_grn_item - add
            @inv_grn_item = @inv_grn.grn_items.build(@inv_grn_item_attributes)

            @inv_grn_item_attributes.merge!({
              product_id:  @inventory_serial_item.product_id,
              recieved_quantity: 1,
              remaining_quantity: 1,
              reserved_quantity: 0,
              damage_quantity: (params[:damage_reason_check].present? ? 1 : 0),
              current_unit_cost: @inv_grn_item.unit_cost,
              srr_item_id: @inv_srr_item.id,
              inventory_not_updated: false,
              main_product_id: nil
            })

            @inv_grn_item.attributes = @inv_grn_item_attributes

            # inv_grn_serial_item - Add
            @inv_grn_serial_item = @inv_grn_item.grn_serial_items.build
            @inv_grn_serial_item.serial_item_id = @inventory_serial_item.id
            @inv_grn_serial_item.remaining = 1
            @inv_grn.save

            @inv_grn_item.grn_item_current_unit_cost_histories.create created_by: current_user.id, current_unit_cost: @inv_grn_item.current_unit_cost

            # inv_damage - Add
            if params[:damage_reason_check].present?
              #inv_inventory Edit
              @inventory_serial_item.inventory.update({
                stock_quantity: (@inventory_serial_item.inventory.stock_quantity.to_f + 1),
                damage_quantity: (@inventory_serial_item.inventory.damage_quantity.to_f + 1)
              })
              @inv_damage = Damage.new({
                store_id: @inv_srr.store.id,
                product_id: @inventory_serial_item.product_id,
                grn_item_id: @inv_grn_item.id,
                grn_batch_id: nil,
                grn_serial_item_id: @inv_grn_serial_item.id,
                grn_serial_part_id: nil,
                spare_part: @inventory_serial_item.inventory_product.spare_part,
                quantity: 1,
                unit_cost: @inv_grn_item.unit_cost,
                currency_id: @inv_grn_item.currency_id,
                srr_item_id: @inv_srr_item.id,
                product_condition_id: @inventory_serial_item.product_condition.id,
                damage_reason_id: params[:damage_reason],
                repair_quantity: 0,
                spare_quantity: 0,
                disposal_quantity: 0,
                disposed_quantity: 0
              })

              @inv_damage.save
            else
              @inventory_serial_item.inventory.update({ 
                stock_quantity: (@inventory_serial_item.inventory.stock_quantity.to_f + 1), 
                available_quantity: (@inventory_serial_item.inventory.available_quantity.to_f + 1)
              })
              
            end

            # inv_gin_item - edit
            @inv_gin_source.gin_item.update returned_quantity: (@inv_gin_source.gin_item.returned_quantity.to_i + 1), return_completed: (@inv_gin_source.gin_item.returnable && (@inv_gin_source.gin_item.issued_quantity.to_i == (@inv_gin_source.gin_item.returned_quantity.to_i + 1)))

            # inv_gin_source - edit
            @inv_gin_source.update returned_quantity: (@inv_gin_source.returned_quantity.to_i + 1)

            # inv_srn_item - edit
            @inv_srn_item.update closed: true, return_completed: (@inv_srn_item.returnable)

            # inv_srr - edit
            @inv_srr.update closed: true

            # inv_srr_item - edit
            @inv_srr_item.update closed: true

            @returned = true

          elsif @inventory_batch.present?  # Inventory Batch Item Returned

            @inventory_batch_attributes = inventory_batch_params
            @grn_item_attributes = {}

            if @add_rec # Add new record (Batch)
              # inv_inventory_batch - Add
              @grn_item_attributes.merge! grn_item_params

              @inventory_batch_attributes.merge! product_id: @inv_gin_source.grn_batch.inventory_batch.inventory_product.id if !@inventory_batch_attributes[:product_id].present?

              @inventory_batch_attributes.merge! inventory_id: Inventory.where(product_id: @inventory_batch_attributes[:product_id], store_id: @inv_srr.store.id).first.id

              # inv_warranty - Add
              # inv_batch_warranty - Add   
              if params[:warranty_check]
                @inv_warranty = InventoryWarranty.new inventory_warranty_params
                @inv_warranty.created_by = current_user.id
                @inv_warranty.save

                @inventory_batch.inventory_warranties << @inv_warranty
              end

            else # update record (Batch)
              # inv_inventory_batch - Edit

              #new grn cost similar to last grn cost 
              @grn_item_attributes.merge!(unit_cost: @inv_gin_source.grn_batch.grn_item.unit_cost, currency_id: @inv_gin_source.grn_batch.grn_item.currency_id)
            end

            @inventory_batch.attributes = @inventory_batch_attributes
            @inventory_batch.created_by = current_user.id
            @inventory_batch.save

            # inv_grn - add
            @inv_grn = Grn.new store_id: @inv_srr.store.id, grn_no: CompanyConfig.first.increase_inv_last_grn_no, srr_id: @inv_srr.id, created_by: current_user.id

              # inv_grn_item - add
            @inv_grn_item = @inv_grn.grn_items.build(@grn_item_attributes)
            @grn_item_attributes.merge!({
              product_id:  @inventory_batch.product_id,
              recieved_quantity: @inv_srr_item.quantity,
              remaining_quantity: @inv_srr_item.quantity,
              reserved_quantity: 0,
              damage_quantity: (params[:damage_reason_check].present? ? @inv_srr_item.quantity : 0),
              current_unit_cost: @inv_grn_item.unit_cost,
              srr_item_id: @inv_srr_item.id,
              inventory_not_updated: false,
              main_product_id: nil
            })
            @inv_grn_item.attributes = @grn_item_attributes

            # inv_grn_batch
            @inv_grn_batch = @inv_grn_item.grn_batches.build
            @inv_grn_batch.inventory_batch_id = @inventory_batch.id
            @inv_grn_batch.recieved_quantity = @inv_srr_item.quantity
            @inv_grn_batch.remaining_quantity = @inv_srr_item.quantity
            @inv_grn_batch.damage_quantity = params[:damage_reason_check].present? ? @inv_srr_item.quantity : 0
            @inv_grn.save

            @inv_grn_item.grn_item_current_unit_cost_histories.create created_by: current_user.id, current_unit_cost: @inv_grn_item.current_unit_cost

            #inv_inventory Edit
            @inventory_batch.inventory.increment! :stock_quantity, @inv_srr_item.quantity

            if params[:damage_reason_check].present?
              @inventory_batch.inventory.increment! :damage_quantity, @inv_srr_item.quantity

            else
              @inventory_batch.inventory.increment! :available_quantity, @inv_srr_item.quantity

            end

            # inv_damage - Add
            if params[:damage_reason_check].present?
              @inv_damage = Damage.new({
                store_id: @inv_srr.store.id,
                product_id: @inventory_batch.product_id,
                grn_item_id: @inv_grn_item.id,
                grn_batch_id: @inv_grn_batch.id,
                grn_serial_item_id: nil,
                grn_serial_part_id: nil,
                spare_part: @inventory_batch.inventory_product.spare_part,
                quantity: @inv_srr_item.quantity,
                unit_cost: @inv_grn_item.unit_cost,
                currency_id: @inv_grn_item.currency_id,
                srr_item_id: @inv_srr_item.id,
                product_condition_id: nil,
                damage_reason_id: params[:damage_reason],
                repair_quantity: 0,
                spare_quantity: 0,
                disposal_quantity: 0,
                disposed_quantity: 0
              })

              @inv_damage.save
            end

            # inv_gin_item - edit
            @inv_gin_source.gin_item.update returned_quantity: (@inv_gin_source.gin_item.returned_quantity.to_i + @inv_srr_item.quantity), return_completed: (@inv_gin_source.gin_item.returnable && (@inv_gin_source.gin_item.issued_quantity.to_i == (@inv_gin_source.gin_item.returned_quantity.to_i + @inv_srr_item.quantity)))

            # inv_gin_source - edit
            @inv_gin_source.update returned_quantity: (@inv_gin_source.returned_quantity.to_i + @inv_srr_item.quantity)

            # inv_srn_item - edit
            @inv_srn_item.update closed: true, return_completed: (@inv_srn_item.returnable)

            # inv_srr - edit
            @inv_srr.update closed: true

            # inv_srr_item - edit
            @inv_srr_item.update closed: true

            @returned = true

          elsif @grn_item.present? # Inventory Item Returned (Not Serial Part, Serial Item or Inventory Batch Item)

            if @add_rec # Add new record

              # inv_grn - add
              @inv_grn = Grn.new store_id: @inv_srr.store.id, grn_no: CompanyConfig.first.increase_inv_last_grn_no, srr_id: @inv_srr.id, created_by: current_user.id
              @inv_grn.grn_items << @grn_item

              # inv_grn_item - add
              if !@grn_item.product_id
                @grn_item.product_id = @inv_gin_source.grn_item.product_id  
              end
              @grn_item.recieved_quantity = @inv_srr_item.quantity
              @grn_item.remaining_quantity = @inv_srr_item.quantity
              @grn_item.reserved_quantity = 0
              @grn_item.damage_quantity = params[:damage_reason_check].present? ? @inv_srr_item.quantity : 0
              #@grn_item.unit_cost - binded
              #@grn_item.currency_id - binded
              @grn_item.current_unit_cost = @grn_item.unit_cost 
              @grn_item.srr_item_id = @inv_srr_item.id
              @grn_item.inventory_not_updated = false
              @grn_item.main_product_id = nil
              @inv_grn.save

              @grn_item.grn_item_current_unit_cost_histories.create created_by: current_user.id, current_unit_cost: @grn_item.current_unit_cost

              #inv_inventory Edit
              @inv_inventory = Inventory.where(product_id: @grn_item.product_id, store_id: @inv_srr.store.id).first

              @inv_inventory.increment! :stock_quantity, @inv_srr_item.quantity

              if params[:damage_reason_check].present?
                @inv_inventory.increment! :damage_quantity, @inv_srr_item.quantity if @inv_inventory.present?
              else
                @inv_inventory.increment! :available_quantity, @inv_srr_item.quantity if @inv_inventory.present?
              end

              # inv_damage - Add
              if params[:damage_reason_check].present?
                @inv_damage = Damage.new({
                  store_id: @inv_srr.store.id,
                  product_id: @grn_item.product_id,
                  grn_item_id: @grn_item.id,
                  grn_batch_id: nil,
                  grn_serial_item_id: nil,
                  grn_serial_part_id: nil,
                  spare_part: @grn_item.inventory_product.spare_part,
                  quantity: @inv_srr_item.quantity,
                  unit_cost: @grn_item.unit_cost,
                  currency_id: @grn_item.currency_id,
                  srr_item_id: @inv_srr_item.id,
                  product_condition_id: nil,
                  damage_reason_id: params[:damage_reason],
                  repair_quantity: 0,
                  spare_quantity: 0,
                  disposal_quantity: 0,
                  disposed_quantity: 0
                })

                @inv_damage.save
              end

              # inv_gin_item - edit
              @inv_gin_source.gin_item.update returned_quantity: (@inv_gin_source.gin_item.returned_quantity.to_i + @inv_srr_item.quantity), return_completed: (@inv_gin_source.gin_item.returnable && (@inv_gin_source.gin_item.issued_quantity.to_i == (@inv_gin_source.gin_item.returned_quantity.to_i + @inv_srr_item.quantity)))

              # inv_gin_source - edit
              @inv_gin_source.update returned_quantity: (@inv_gin_source.returned_quantity.to_i + @inv_srr_item.quantity)

              # inv_srn_item - edit
              @inv_srn_item.update closed: true, return_completed: (@inv_srn_item.returnable)

              # inv_srr - edit
              @inv_srr.update closed: true

              # inv_srr_item - edit
              @inv_srr_item.update closed: true
            #else # update record
              # Not Applicable
            end
            @returned = true

          end


          if @returned

            if @onloan_request

              @onloan_request_part.update ret_part_received: true, ret_part_received_at: DateTime.now, ret_part_received_by: current_user.id

              # 54 Receive Returned On-Loan part
              action_id = TaskAction.find_by_action_no(54).id

              @onloan_request_part.update status_action_id: SparePartStatusAction.find_by_code("RPA").id # Returned Part Accepted
              @onloan_request_part.ticket_on_loan_spare_part_status_actions.create(status_id: @onloan_request_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

              @onloan_request_part.update status_action_id: SparePartStatusAction.find_by_code("CLS").id # Close
              @onloan_request_part.ticket_on_loan_spare_part_status_actions.create(status_id: @onloan_request_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

              user_ticket_action = @onloan_request_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @onloan_request_part.ticket.re_open_count, action_id: action_id)
              user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: @onloan_request_part.id)
              user_ticket_action.save

            else #Store Request (not On-Loan)

              @ticket_spare_part.update  returned_part_accepted: true

              # 43 Receive Returned part
              action_id = TaskAction.find_by_action_no(43).id

              @ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("RPA").id # Returned Part Accepted
              @ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

              @ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("CLS").id # Close
              @ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

              user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id)
              user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)
              user_ticket_action.save

            end

            bpm_variables = view_context.initialize_bpm_variables

            bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

            if bpm_response[:status].upcase == "SUCCESS"
              flash[:notice] = "Successfully updated."
            else
              flash[:error] = "ticket is updated. but Bpm error"
            end

          end
        end
      end
    else
      flash[:notice] = "ticket is not updated. Bpm error"
    end
    redirect_to todos_url

  end

  def update_estimate_the_part_internal

    TaskAction
    Tax
    estimation = TicketEstimation.find params[:part_estimation_id]
    @ticket = Ticket.find params[:ticket_id]
    requested_quantity = params[:requested_quantity]

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue

      if estimation.estimation_status.code == 'RQS'

        if estimation.ticket_estimation_parts.any? { |p| p.ticket_spare_part.spare_part_status_action.code == "CLS" }
          estimation.update status_id: EstimationStatus.find_by_code("CLS").id
          @jump_next = true
          d19_estimate_internal_below_margin = "N"
          flash[:notice]= "Requested Part is terminated."
        else
          estimation.update estimation_params

          #If Part has changed by chargeable eng
          if params[:store_id].present?
            estimation.ticket_estimation_parts.each do |p|
              if p.ticket_spare_part.ticket_spare_part_store.present?
                p.ticket_spare_part.ticket_spare_part_store.update(store_id: params[:store_id], inv_product_id: params[:inv_product_id], requested_quantity: requested_quantity)
              end
              if p.ticket_spare_part.ticket_spare_part_non_stock.present?
                p.ticket_spare_part.ticket_spare_part_non_stock.update(store_id: params[:store_id], inv_product_id: params[:inv_product_id], requested_quantity: requested_quantity)
              end
            end
          end

          t_cost_price = estimation.ticket_estimation_parts.sum(:cost_price).to_f + estimation.ticket_estimation_additionals.sum(:cost_price).to_f

          t_est_price = estimation.ticket_estimation_parts.sum(:estimated_price).to_f + estimation.ticket_estimation_additionals.sum(:estimated_price).to_f

          if t_est_price > 0
            estimation.update_attribute(:cust_approval_required, true)

            d19_estimate_internal_below_margin = (((t_est_price - t_cost_price)*100/t_cost_price) < CompanyConfig.first.try(:sup_internal_part_profit_margin).to_f) ? "Y" : "N"
          else
            estimation.update_attribute(:cust_approval_required, false)
            d19_estimate_internal_below_margin = "N"
          end

          @jump_next = params[:estimation_complete_check].to_bool if params[:estimation_complete_check].present?
          if @jump_next
            if d19_estimate_internal_below_margin == "N"

              estimation.ticket_estimation_parts.each do |p|
                p.ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("ECM").id) #Estimation Completed
                p.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: p.ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)
              end

              estimation.update status_id: EstimationStatus.find_by_code('EST').id            
            end
            
            estimation.update_attribute(:approval_required, (d19_estimate_internal_below_margin == "Y" ? true : false))
            estimation.update_attributes(estimated_at: DateTime.now, estimated_by: current_user.id)

            #Set Action (74) part estimation completed, DB.spt_act_request_spare_part
            user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(74).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
            user_ticket_action.build_act_job_estimation(ticket_estimation_id: estimation.id)
            user_ticket_action.save

          end
        end

        if @jump_next
          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables.merge(d19_estimate_internal_below_margin: d19_estimate_internal_below_margin)

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"

            # WebsocketRails[:posts].trigger 'new', {task_name: "Spare part", task_id: spt_ticket_spare_part.id, task_verb: "received and issued.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

            flash[:notice]= "Successfully updated"
          else
            flash[:error]= "Estimate part is updated. but Bpm error"
          end
        else
          flash[:error] = "Estimate updated. But not completed."
        end

      else
        flash[:error] = "Already estimated."
        bpm_variables = view_context.initialize_bpm_variables
        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables
      end
    else
      flash[:error]= "Unable to update. Bpm error"
    end
    redirect_to todos_url
  end

  def update_low_margin_estimate_parts_approval

    TaskAction
    estimation = TicketEstimation.find params[:part_estimation_id]
    @ticket = Ticket.find params[:ticket_id]

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue

      if estimation.estimation_status.code == 'RQS'

        if estimation.ticket_estimation_parts.any? { |p| p.ticket_spare_part.spare_part_status_action.code == "CLS" }
          estimation.update status_id: EstimationStatus.find_by_code("CLS").id
          @jump_next = true
          flash[:notice]= "Requested Part is terminated."
        else
          estimation.update estimation_params

          t_est_price = estimation.ticket_estimation_parts.sum(:approved_estimated_price).to_f + estimation.ticket_estimation_additionals.sum(:approved_estimated_price).to_f

          if t_est_price > 0
            estimation.update_attribute(:cust_approval_required, true)
          else
            estimation.update_attribute(:cust_approval_required, false)
          end

          @jump_next = params[:approval_complete_check].to_bool if params[:approval_complete_check].present?
          if @jump_next

            estimation.ticket_estimation_parts.each do |p|
              p.ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("ECM").id) #Estimation Completed
              p.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: p.ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)
            end

            @ticket.update_attribute(:status_resolve_id, TicketStatusResolve.find_by_code("EST").id)# (Estimated).
            estimation.update status_id: EstimationStatus.find_by_code('EST').id, approved: true, approved_at: DateTime.now, approved_by: current_user.id

            #Set Action (75) Part Estimation Customer Aproved, DB.spt_act_job_estimate
            user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(75).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
            user_ticket_action.build_act_job_estimation(ticket_estimation_id: estimation.id)
            user_ticket_action.save

          end
        end

        if @jump_next
          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"

            # WebsocketRails[:posts].trigger 'new', {task_name: "Spare part", task_id: spt_ticket_spare_part.id, task_verb: "received and issued.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

            flash[:notice]= "Successfully updated"
          else
            flash[:error]= "Estimate part is updated. but Bpm error"
          end
        else
          flash[:error] = "Estimate updated. But not completed."
        end

      else
        flash[:error] = "Already estimated."
        bpm_variables = view_context.initialize_bpm_variables
        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables
      end
    else
      flash[:error]= "Unable to update. Bpm error"
    end
    redirect_to todos_url

  end

  def product_info
    Inventory
    @product = InventoryProduct.find params[:product_id]
    stock_quantity = @product.inventories.find_by_store_id(params[:store_id]).try(:stock_quantity)
    item_type = @product.inventory_product_info.need_serial ? "Serial" : @product.inventory_product_info.need_batch ? "Batch" : "Non Serial or Non Batch"
    product_filter_json = {generated_item_code: @product.generated_item_code, description: @product.description, unit: @product.inventory_unit.unit, stock_in_hand: stock_quantity, item_type: item_type}
    render json: product_filter_json
  end

  def toggle_add_update_return_part
    Ticket
    Warranty

    Inventory

    object_id = params[:object_id] if params[:object_id] != "undefined"
    @uri = URI params[:uri]

    if params[:active_spare_part].present? and params[:active_spare_part] != "undefined"
      active_spare_part_class, active_spare_part_id = params[:active_spare_part].split("-")
      @ticket_spare_part = active_spare_part_class.classify.constantize.find(active_spare_part_id)
    end

    case params[:object_class]

    when "InventorySerialPart", "InventorySerialItem"
      if object_id.present?
        @form_serial_part_or_item = params[:object_class].classify.constantize.find(object_id)
      else
        @form_serial_part_or_item = params[:object_class].classify.constantize.new
      end

      @main_part_of_serial_part = InventorySerialItem.find(session[:serial_part_item_id]) if session[:serial_part_item_id].present?


      @template = "serial_or_item_form"
      @variables = {form_serial_part_or_item: @form_serial_part_or_item, uri: @uri, main_part_of_serial_part: @main_part_of_serial_part, ticket_spare_part: @ticket_spare_part, currency_code: params[:currency_code], currency_id: params[:currency_id], grn_cost: params[:grn_cost]}
    when "InventoryBatch"
      if object_id.present?
        @form_inv_batch = params[:object_class].classify.constantize.find(object_id)
      else
        @form_inv_batch = params[:object_class].classify.constantize.new
      end
      @template = "grn_batch_form"
      @variables = {form_inv_batch: @form_inv_batch, uri: @uri, ticket_spare_part: @ticket_spare_part, currency_code: params[:currency_code], currency_id: params[:currency_id], grn_cost: params[:grn_cost]}
    when "GrnItem"
      if object_id.present?
        @form_grn_item = params[:object_class].classify.constantize.find(object_id)
      else
        @form_grn_item = params[:object_class].classify.constantize.new
      end
      @template = "grn_item_form"
      @variables = {form_grn_item: @form_grn_item, uri: @uri, ticket_spare_part: @ticket_spare_part, currency_id: params[:currency_id], grn_cost: params[:grn_cost]}
    else
      @template = "reject"
      @variables = {form_grn_item: @form_grn_item, uri: @uri, ticket_spare_part: @ticket_spare_part}
    end

    respond_to do |format|
    format.js {render "tickets/tickets_pack/return_store_part/toggle_add_update_return_part"}
    end
  end

  def load_serial_and_part
    Inventory
    approved_part_product_id = params[:approved_part_product_id]
    if params[:inventory_type] == "serial_part"
      @inventory_type = InventorySerialPart.find params[:inventory_type_id]
    elsif params[:inventory_type] == "serial_item"
      @inventory_type = InventorySerialItem.find params[:inventory_type_id]

      # @inventory_serial_parts = @inventory_type.inventory_serial_parts
      @inventory_serial_parts = Kaminari.paginate_array(@inventory_type.inventory_serial_parts.where(product_id: approved_part_product_id)).page(params[:page]).per(10)
    end

  end

  def generate_serial_no
    Inventory
    # products = InventoryProduct.order("serial_no DESC").where(category3_id: params[:category3_id]).map{|p| {serialNo: p.generated_serial_no, description: p.description}}
    @show_generate_serial_button = (params[:category]["category3_id"].present? and params[:category]["category3_id"] != "undefined")

    # puts params[:category]["category3_id"].present? and params[:category]["category3_id"] != "undefined"

    params[:query] = params[:category].map { |k, v| "#{k}:#{v}" if v.present? and v != "undefined"  }.compact.join(" AND ")

    #((((((((()))))))))
    params[:order] = "desc"
    params[:order_by_field] = :serial_no
    #((((((((()))))))))

    # @products = InventoryProduct.search(params).map { |p| {serialNo: p.serial_no, generatedItemCode: p.generated_item_code, description: p.description}}

    # @products = Kaminari.paginate_array(InventoryProduct.search(params)).page(params[:page]).per(10)
    @products = InventoryProduct.search(params)




    # products = InventoryProduct.advance_search(params).hits.hits.map{|h| h["_source"]}.map { |p| {serialNo: p["serial_no"], generatedItemCode: p["generated_item_code"], description: p["description"]}}
    # render json: @products
  end

  private

    def find_ticket
      @ticket = Ticket.find params[:ticket_id]
    end

    def destroy_task_cache
      Rails.cache.delete(session[:cache_key])
    end

    def ticket_spare_part_params spt_ticket_spare_part
      tspt_params = params.require(:ticket_spare_part).permit(:approved_store_id, :unused_reason_id, :approved_inv_product_id, :approved_main_inv_product_id, :spare_part_no, :spare_part_description, :ticket_id, :ticket_fsr, :cus_chargeable_part, :request_from, :faulty_serial_no, :received_part_serial_no, :received_part_ct_no, :repare_start, :repare_end, :return_part_serial_no, :return_part_ct_no, :faulty_ct_no, :note, :status_action_id, :part_terminated, :status_use_id, :part_terminated_reason_id, :received_spare_part_no, :returned_part_accepted, ticket_attributes: [:remarks, :id], ticket_spare_part_manufacture_attributes: [:id, :event_no, :order_no, :id, :event_closed, :ready_to_bundle, :payment_expected_manufacture], ticket_spare_part_store_attributes: [:part_of_main_product, :id, :approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :store_request_approved, :return_part_damage, :return_part_damage_reason_id], request_spare_parts_attributes: [:reject_return_part_reason_id, :return_part_damage, :return_part_damage_reason_id], ticket_on_loan_spare_parts_attributes: [:id, :approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :approved, :ticket_id, :return_part_damage, :return_part_damage_reason_id] )

      tspt_params[:repare_start] = Time.strptime(tspt_params[:repare_start],'%m/%d/%Y %I:%M %p') if tspt_params[:repare_start].present?
      tspt_params[:repare_end] = Time.strptime(tspt_params[:repare_end],'%m/%d/%Y %I:%M %p') if tspt_params[:repare_end].present?

      spt_ticket_spare_part.current_user_id = current_user.id
      tspt_params
    end

    def ticket_on_loan_spare_part_params ticket_onloan_spare_part
      t_onloan_spare_part = params.require(:ticket_on_loan_spare_part).permit(:return_part_serial_no, :return_part_ct_no, :unused_reason_id, :note, :part_terminated_reason_id, :approved, :approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :ref_spare_part_id, :note, :ticket_id, :status_action_id, :status_use_id, :store_id, :inv_product_id, :main_inv_product_id, :part_of_main_product, :received_part_serial_no, :received_part_ct_no, :return_part_damage, :return_part_damage_reason_id, :return_part_damage, :return_part_damage_reason_id, ticket_attributes: [:remarks, :id])

      t_onloan_spare_part[:note] = t_onloan_spare_part[:note].present? ? "#{t_onloan_spare_part[:note]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_onloan_spare_part.note}" : ticket_onloan_spare_part.note
      t_onloan_spare_part
    end

    def estimation_params
      estimation_params = params.require(:ticket_estimation).permit(:note, :id, :cust_approved, :cust_approved_by, :request_type, :advance_payment_amount, :current_user_id, :approved_adv_pmnt_amount, ticket_estimation_parts_attributes: [:id, :supplier_id, :cost_price, :estimated_price, :warranty_period, :approved_estimated_price, ticket_spare_part_attributes: [:id, :current_user_id, :note], ticket_estimation_part_taxes_attributes: [:id, :_destroy, :tax_id, :tax_rate, :estimated_tax_amount, :approved_tax_amount]], ticket_estimation_additionals_attributes: [:id, :_destroy, :ticket_id, :additional_charge_id, :cost_price, :estimated_price, :approved_estimated_price, ticket_estimation_additional_taxes_attributes: [ :id, :_destroy, :tax_id, :tax_rate, :estimated_tax_amount, :approved_tax_amount ]], ticket_estimation_externals_attributes: [:id, :_destroy, :ticket_id, :description, :repair_by_id, :cost_price, :estimated_price, :warranty_period, :approved_estimated_price, ticket_estimation_external_taxes_attributes: [:id, :_destroy, :tax_id, :tax_rate, :estimated_tax_amount, :approved_tax_amount]])
      estimation_params[:current_user_id] = current_user.id
      estimation_params
    end

    def inventory_serial_part_params
      params.require(:inventory_serial_part).permit(:id, :serial_item_id, :product_id, :serial_no, :remarks, :product_condition_id, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :disposed, :inv_status_id, :ct_no, :manufatured_date, :expiry_date, :inventory_serial_part_or_item_id, inventory_serial_item_attributes: [:id, :inventory_id, :product_id, :batch_id, :serial_no, :remarks, :product_condition_id, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :disposed, :inv_status_id, :ct_no, :manufatured_date, :expiry_date])
    end

    def inventory_serial_item_params
      params.require(:inventory_serial_item).permit(:id, :inventory_id, :product_id, :batch_id, :serial_no, :remarks, :product_condition_id, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :disposed, :inv_status_id, :ct_no, :manufatured_date, :expiry_date)
    end

    def grn_batch_params
      params.require(:grn_batch).permit(:id, :grn_item_id, :inventory_batch_id, :recieved_quantity, :remaining_quantity, :reserved_quantity, :damage_quantity)
    end

    def grn_item_params
      params.require(:grn_item).permit(:id, :grn_id, :srn_item_id, :product_id, :recieved_quantity, :remaining_quantity, :reserved_quantity, :damage_quantity, :remarks, :unit_cost, :current_unit_cost, :currency_id, :average_cost, :standard_cost, :po_item_id, :po_unit_quantity, :po_unit_cost, :grn_item_id)
    end

    def inventory_batch_params
      params.require(:inventory_batch).permit(:id, :inventory_id, :product_id, :lot_no, :batch_no, :remarks, :manufatured_date, :expiry_date, :created_at, :created_by)
    end

    def inventory_warranty_params
      params.require(:inventory_warranty).permit(:id, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :warranty_type_id, :remarks)
    end

    def ticket_params
      ticket_params = params.require(:ticket).permit(:ticket_no, :note, :sla_id, :serial_no, :status_hold, :repair_type_id, :base_currency_id, :ticket_close_approval_required, :ticket_close_approval_requested, :regional_support_job, :job_started_action_id, :job_start_note, :job_started_at, :contact_type_id, :cus_chargeable, :informed_method_id, :job_type_id, :other_accessories, :priority, :problem_category_id, :problem_description, :remarks, :inform_cp, :resolution_summary, :status_id, :ticket_type_id, :warranty_type_id, :status_resolve_id, ticket_deliver_units_attributes: [:id, :deliver_to_id, :note, :collected, :delivered_to_sup, :created_at, :created_by, :received, :received_at, :received_by, :current_user_id], ticket_accessories_attributes: [:id, :accessory_id, :note, :_destroy], q_and_answers_attributes: [:problematic_question_id, :answer, :ticket_action_id, :id], joint_tickets_attributes: [:joint_ticket_id, :id, :_destroy], ge_q_and_answers_attributes: [:id, :general_question_id, :answer], ticket_estimations_attributes: [:id, :advance_payment_amount, :note, :currency_id, :status_id, :requested_at, :requested_by, :request_type, :approved_adv_pmnt_amount, :current_user_id, ticket_estimation_parts_attributes: [:id, :supplier_id, :cost_price, :estimated_price, :warranty_period, :approved_estimated_price, ticket_estimation_part_taxes_attributes: [:id, :_destroy, :tax_id, :tax_rate, :estimated_tax_amount, :approved_tax_amount]], ticket_estimation_externals_attributes: [:id, :repair_by_id, :cost_price, :estimated_price, :warranty_period, :approved_estimated_price, ticket_estimation_external_taxes_attributes: [:id, :_destroy, :tax_id, :estimated_tax_amount, :approved_tax_amount, :tax_rate]], ticket_estimation_additionals_attributes: [:ticket_id, :additional_charge_id, :cost_price, :estimated_price, :_destroy, :id, :approved_estimated_price, ticket_estimation_additional_taxes_attributes: [:id, :_destroy, :tax_id, :estimated_tax_amount, :approved_tax_amount, :tax_rate]]], user_ticket_actions_attributes: [:id, :_destroy, :action_at, :action_by, :action_id, :re_open_index, user_assign_ticket_action_attributes: [:sbu_id, :_destroy, :assign_to, :recorrection], assign_regional_support_centers_attributes: [:regional_support_center_id, :_destroy], ticket_re_assign_request_attributes: [:reason_id, :_destroy], ticket_action_taken_attributes: [:action, :_destroy], ticket_terminate_job_attributes: [:id, :reason_id, :foc_requested, :_destroy], act_hold_attributes: [:id, :reason_id, :_destroy, :un_hold_action_id], hp_case_attributes: [:id, :case_id, :case_note], ticket_finish_job_attributes: [:resolution, :_destroy], act_terminate_job_payments_attributes: [:id, :amount, :payment_item_id, :_destroy, :ticket_id, :currency_id], act_fsr_attributes: [:print_fsr], serial_request_attributes: [:reason], job_estimation_attributes: [:supplier_id]], ticket_extra_remarks_attributes: [:id, :note, :created_by, :extra_remark_id], products_attributes: [:id, :sold_country_id, :pop_note, :pop_doc_url, :pop_status_id], ticket_fsrs_attributes: [:work_started_at, :work_finished_at, :hours_worked, :down_time, :travel_hours, :engineer_time_travel, :engineer_time_on_site, :resolution, :completion_level, :created_by], ticket_on_loan_spare_parts_attributes: [:id, :approved_inv_product_id, :approved_store_id, :approved_main_inv_product_id, :approved, :return_part_damage, :return_part_damage_reason_id], act_terminate_job_payments_attributes: [:id, :_destroy, :payment_item_id, :amount, :currency_id])
      ticket_params[:current_user_id] = current_user.id
      ticket_params
    end

    def inveestimated_tax_amountntory_product_params
      params.require(:inventory_product).permit(:serial_no, :serial_no_order, :legacy_code, :sku, :model_no, :product_no, :spare_part_no, :description, :fifo)
    end
end