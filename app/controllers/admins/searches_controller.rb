module Admins
  class SearchesController < ApplicationController
    layout "admins"

    def search_grn
      Inventory
      User
      Grn
      refined_search_grn = ""
      if params[:search].present?
        search_grn = params[:search_grn]
        refined_search_grn = search_grn.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      end

      params[:query] = refined_search_grn
      @grns = Grn.search(params)

      case params[:grn_callback]
      when "select_grn"
        @grn = Grn.find params[:grn_id]
        render "admins/searches/grn/select_grn"
      when "change_cost"
        @grnitem = GrnItem.find params[:grnitem_id]
        render "admins/searches/grn/change_cost"
      else
        render "admins/searches/grn/search_grn"
      end
    end

    def inventories
      Grn
      Inventory
      User
      Product
      @remote = true
      @inv_searched_by = true
      @store = Organization.find params[:store_id] if params[:store_id].present?
      @inv_pro = InventoryProduct.find params[:product_id] if params[:product_id].present?
      @inventory = @inv_pro.inventories.find_by_store_id(@store.id) if @inv_pro.present? and @store.present?

      @total_stock_cost = @inv_pro.stock_cost(@inventory.try(:id)) if @inv_pro.present?

      query = "inventory_product.id:#{@inv_pro.try(:id)}"

      case params[:type]
      when "Serial"

        if @store.present?
          # p = Tire.search 'inventory_serial_items', {"query":{"bool":{"must":[{"query_string":{"query":"inventory.store_id:18 AND inventory_product.id:13"}}]}},"sort":[{"created_at":{"order":"desc","ignore_unmapped":true}}], "aggs": {"stock_cost": {"sum": {"field": "remaining_grn_items.current_unit_cost"}}}}

          query = [query, "inventory.store_id:#{@store.id}", "NOT inventory_serial_item_status.name: Not Available"].join(" AND ")
        end

        params[:query] = query

        @inventory_serial_items = InventorySerialItem.search(params)

        render "admins/searches/inventory/select_serial_items"

      when "Batch"
        if @store.present?
          query = [query, "inventory.store_id:#{@store.id}", "grn_batches.remaining_quantity:>0"].join(" AND ")

        end

        params[:query] = query

        @inventory_batches = InventoryBatch.search(params)

        render "admins/searches/inventory/select_batches"
        
      when "Non Serial Non Batch"
        if @store.present?
          # p = Tire.search 'inventory_serial_items', {"query":{"bool":{"must":[{"query_string":{"query":"inventory.store_id:18 AND inventory_product.id:13"}}]}},"sort":[{"created_at":{"order":"desc","ignore_unmapped":true}}], "aggs": {"stock_cost": {"sum": {"field": "remaining_grn_items.current_unit_cost"}}}}

          query = [query, "grn.store_id:#{@store.id}"].join(" AND ")
        end

        params[:query] = query
        # @non_serial_or_batches = @inv_pro.grn_items.only_grn_items1.select{|g| @store.present? ? (g if @store.id == g.grn.store_id) : g }.compact
        @non_serial_or_batches = GrnItem.search(params)
        # @ans = @non_serial_or_batches.inject(0){|i, k| i + k.remaining_quantity*k.current_unit_cost}

        # @non_serial_or_batches = Kaminari.paginate_array(@non_serial_or_batches).page(params[:page]).per(10)

        # @total_stock_cost = @grn_items.sum{|i| i.grn_items.sum{ |g| g.any_remaining_serial_item ? g.current_unit_cost.to_f*g.remaining_quantity.to_f : 0 }}

        render "admins/searches/inventory/select_non_serial_or_batch"
        
      else
        case params[:select_action]

        when "select_serial_item_more"
          @inventory_serial_item = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
          @inventory_serial_parts = @inventory_serial_item.inventory_serial_parts
          # @inventory_serial_item_add_cost = @inventory_serial_item.inventory_serial_items_additional_costs
          render "admins/searches/inventory/select_serial_item_more"

        when "select_inventory_serial_part_more"
          @inventory_serial_part = InventorySerialPart.find params[:inventory_serial_part_id] if params[:inventory_serial_part_id].present?
          render "admins/searches/inventory/select_inventory_serial_part_more"


        when "select_inventory_batch_more"
          @inventory_batch = InventoryBatch.find params[:inventory_batch_id] if params[:inventory_batch_id].present?

          render "admins/searches/inventory/select_inventory_batch_more"

        when "select_non_serial_or_batch_more"
          @inventory_non_serial_non_batch = GrnItem.find(params[:grn_item_id]) if params[:grn_item_id].present?
          render "admins/searches/inventory/select_non_serial_or_batch_more"
        else
          render "admins/searches/inventory/inventories"
        end
      end
        
    end

    def search_customers_suppliers
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
      refined_search = "accounts_dealer_types.dealer_code:#{((@select_options and @select_options[:type] == 'customer') or params[:type]) == 'customer' ? '(CUS OR INDCUS)' : '(SUP OR INDSUP)'}"
      if params[:search].present?
        refined_customers_suppliers = params[:search_customers_suppliers][:organization].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

        refined_search = [refined_search, refined_customers_suppliers].map{|v| v if v.present? }.compact.join(" AND ")

      end
      puts refined_search
      params[:query] = refined_search
      @customers_suppliers = Organization.search(params)

      render "admins/searches/customers_suppliers/select_customers_suppliers"
    end

    def search_gins
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
      refined_search = ""
      if params[:search].present?
        refined_gins = params[:search_gins][:gin].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

        refined_search = [refined_search, refined_gins].map{|v| v if v.present? }.compact.join(" AND ")

      end
      puts refined_search
      params[:query] = refined_search
      @gins = Gin.search(params)

      render "admins/searches/gin/select_gin"
    end

    def inventory_serial_item_history
      Inventory
      @inventory_serial_item = InventorySerialItem.find(params[:serial_item_id])

      @history = []

      @inventory_serial_item.grn_items.each do |grn_item|
        @history << { name: "PRN", element: grn_item.inventory_po_item.inventory_prn_item.inventory_prn, created_at: grn_item.inventory_po_item.inventory_prn_item.inventory_prn.created_at.strftime("%Y-%m-%d") } if grn_item.inventory_po_item.present?
        @history << { name: "PO", element: grn_item.inventory_po_item.inventory_po, created_at: grn_item.inventory_po_item.inventory_po.created_at.strftime("%Y-%m-%d") } if grn_item.inventory_po_item.present?
        @history << { name: "GRN", element: grn_item, created_at: grn_item.created_at.strftime("%Y-%m-%d") }

        if grn_item.srn_item.present?
          grn_item.srn_item.gin_items.each do |gin_item|
            @history << { name: "GIN", element: gin_item.gin, created_at: gin_item.gin.created_at.strftime("%Y-%m-%d") }
          end
        end

        @history << { name: "SRN", element: grn_item.srn_item.srn, created_at: grn_item.srn_item.srn.created_at.strftime("%Y-%m-%d") } if grn_item.srn_item.present?
        @history << { name: "SRR", element: grn_item.srr_item.srr, created_at: grn_item.srr_item.srr.created_at.strftime("%Y-%m-%d") } if grn_item.srr_item.present?

      end

      render json: @history.sort{|p, n| n["created_at"] <=> p["created_at"] }

    end

    def search_gin_srr_grn
      if params[:search].present?
        @history = case params[:type]
        when "gin"
          query = { formatted_gin_no: params[:type_no], gin_range_from: params[:from_date], gin_range_to: params[:to_date] }.map { |k, v| "#{k}:#{v}" if v.present? }

          refined_query = query.join(" AND ")

          Gin.search( query: refined_query ).map { |k| { no: k.formatted_gin_no, created_at: k.formated_created_at, created_by: k.created_by_user_full_name } }

        when "srr"
          query = { formatted_srr_no: params[:type_no], range_from: params[:from_date], range_to: params[:to_date] }.map { |k, v| "#{k}:#{v}" if v.present? }

          refined_query = query.join(" AND ")

          Srr.search( query: refined_query ).map { |k| { no: k.formatted_srr_no, created_at: k.formated_created_at, created_by: k.created_by_user_full_name } }

        when "grn"
          query = { grn_no_format: params[:type_no], range_from: params[:from_date], range_to: params[:to_date] }.map { |k, v| "#{k}:#{v}" if v.present? }

          refined_query = query.join(" AND ")

          Grn.search( query: refined_query ).map { |k| { no: k.formatted_grn_no, created_at: k.formated_created_at, created_by: k.created_by_user } }

        end

      end

      render "admins/searches/gin_srr_grn/gin_srr_grn"

    end

    private

      def update_grn_item_params
        params.require(:grn_item).permit(:remarks, :current_user_id, grn_item_current_unit_cost_histories_attributes: [:id, :current_unit_cost, :created_by, :created_at])
      end

      def inv_sitem_addcost_params
        params.require(:inventory_serial_items_additional_cost).permit(:id, :serial_item_id, :cost, :currency_id, :note, :created_by, :created_at)
      end

      def inv_sitem_addcost_update_params
        params.require(:inventory_serial_items_additional_cost).permit(:cost, :note)
      end
  end
end