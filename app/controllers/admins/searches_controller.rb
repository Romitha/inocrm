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

      query = "inventory_product.id:#{@inv_pro.try(:id)} AND NOT inventory_serial_item_status.name: Not Available"

      case params[:type]
      when "Serial"

        if @store.present?
          # p = Tire.search 'inventory_serial_items', {"query":{"bool":{"must":[{"query_string":{"query":"inventory.store_id:18 AND inventory_product.id:13"}}]}},"sort":[{"created_at":{"order":"desc","ignore_unmapped":true}}], "aggs": {"stock_cost": {"sum": {"field": "remaining_grn_items.current_unit_cost"}}}}

          query = [query, "inventory.store_id:#{@store.id}"].join(" AND ")
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
        @non_serial_or_batches = @inv_pro.grn_items.only_grn_items1.select{|g| @store.present? ? (g if @store.id == g.grn.store_id) : g }.compact
        @ans = @non_serial_or_batches.inject(0){|i, k| i + k.remaining_quantity*k.current_unit_cost}

        @non_serial_or_batches = Kaminari.paginate_array(@non_serial_or_batches).page(params[:page]).per(10)

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

    # def search_pos
    #   Inventory
    #   User
    #   PO
    #   refined_search_grn = ""
    #   if params[:search_po].present?
    #     search_po = params[:search_po]
    #     refined_search_po = search_po.map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
    #   end

    #   params[:query] = refined_search_grn
    #   @po = Po.search(params)

    #   case params[:po_callback]
    #   when "view_po"
    #     @po = Po.find params[:po_id]
    #     render "admins/searches/grn/view_po"
    #   else
    #     render "admins/inventories/search_po"
    #   end
    # end

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