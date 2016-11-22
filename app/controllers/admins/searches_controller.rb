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
      @remote = true
      @inv_searched_by = true
      @store = Organization.find params[:store_id] if params[:store_id].present?
      @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?
      # @inv_pro = InventoryProduct.search query: "id:#{params[:inv_pro_id]} AND stores.id:#{params[:store_id]}" if params[:inv_pro_id].present?

      case params[:select_action]

      when "select_serial_items"
        # **************
        # @grn_serial_items = @inv_pro.grn_serial_items#.map { |g| g.inventory_serial_item }
        if @store.present?
          @inventory_serial_items = InventorySerialItem.search(query: "inventory.store_id:#{@store.id} AND inventory_product.id:#{@inv_pro.id}"))
        else
          @inventory_serial_items = InventorySerialItem.search(query: "inventory_product.id:#{@inv_pro.id}"))
        end
        # **************
        # @total_stock_cost = @grn_serial_items.to_a.sum{|g| (g.grn_item.current_unit_cost*g.grn_item.remaining_quantity + g.inventory_serial_item.inventory_serial_items_additional_costs.sum(:cost))}

        @total_stock_cost = @inventory_serial_items.sum{|i| i.grn_items.sum{ |g| g.any_remaining_serial_item ? g.current_unit_cost.to_f*g.remaining_quantity.to_f : 0 } + i.inventory_serial_items_additional_costs.sum{|c| c.cost.to_f }}

        # @inventory_serial_items = Kaminari.paginate_array(@inventory_serial_items).page(params[:page]).per(10)

        render "admins/searches/inventory/select_serial_items"

      when "select_batches"
        # @grn_batches = @inv_pro.grn_batches
        # @grn_batches = Kaminari.paginate_array(@grn_batches).page(params[:page]).per(10)
        if @store.present?
          @inventory_batches = InventoryBatch.search(query: "inventory.store_id:#{@store.id} AND inventory_product.id:#{@inv_pro.id}")
        else
          @inventory_batches = InventoryBatch.search(query: "inventory_product.id:#{@inv_pro.id}")
        end

        @total_stock_cost = @inventory_batches.sum{|i| i.grn_current_unit_cost.to_f*i.remaining_quantity.to_f}

        render "admins/searches/inventory/select_batches"

      when "select_non_serial_or_batch"
        # **************
        @non_serial_or_batches = @inv_pro.grn_items.only_grn_items1
        @ans = @non_serial_or_batches.inject(0){|i, k| i + k.remaining_quantity*k.current_unit_cost}

        @non_serial_or_batches = Kaminari.paginate_array(@non_serial_or_batches).page(params[:page]).per(10)

        # @total_stock_cost = @grn_items.sum{|i| i.grn_items.sum{ |g| g.any_remaining_serial_item ? g.current_unit_cost.to_f*g.remaining_quantity.to_f : 0 }}

        render "admins/searches/inventory/select_non_serial_or_batch"

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