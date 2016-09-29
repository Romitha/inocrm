module Admins
  class SearchesController < ApplicationController
    layout "admins"

    def update_grn_cost
      Inventory
      User
      Grn
      @grnitem = GrnItem.find params[:grnitem_id]
      @grnitem.update update_grn_item_params
      @grnitem.update current_unit_cost: @grnitem.grn_item_current_unit_cost_histories.order(created_at: :desc).first.current_unit_cost
      render "admins/searches/grn/change_cost"
    end

    def search_grn
      Inventory
      User
      Grn
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
      Inventory
      User
      @remote = true
      @inv_searched_by = true
      @store = Organization.find params[:store_id] if params[:store_id].present?

      case params[:select_action]

      when "select_serial_items"
        @store = params[:store]
        @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?
        @inventory_serial_items = Kaminari.paginate_array(@inv_pro.inventory_serial_items).page(params[:page]).per(10)
        tot_cost = 0
        @ans = 0
        @inv_pro.inventory_serial_items.each do |inventory_serial_item|
          add_cost = inventory_serial_item.inventory_serial_items_additional_costs.sum(:cost)
          inventory_serial_item.grn_items.each do |grn_item|
            rem_q = grn_item.remaining_quantity
            crnt_ucost = grn_item.current_unit_cost
            tot_cost = add_cost+(rem_q*crnt_ucost)
            @ans = @ans + tot_cost
          end
        end

        render "admins/searches/inventory/select_serial_items"

      when "select_serial_item_more"
        @store = params[:store]
        @inventory_serial_item_id = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
        @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
        @inventory_serial_item_add_cost = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_items_additional_costs).page(params[:page]).per(10)
        render "admins/searches/inventory/select_serial_item_more"

      when "select_inventory_serial_part_more"
        @store = params[:store]
        @inventory_serial_part_id = InventorySerialPart.find params[:inventory_serial_part_id] if params[:inventory_serial_part_id].present?
        render "admins/searches/inventory/select_inventory_serial_part_more"
        @inventory_serial_item_part_add_cost = Kaminari.paginate_array(@inventory_serial_part_id.inventory_serial_part_additional_costs).page(params[:page]).per(10)

      when "select_batches"
        @store = params[:store]
        @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?
        @inventory_batches = Kaminari.paginate_array(@inv_pro.inventory_batches).page(params[:page]).per(10)
        tot_cost = 0
        @ans = 0
        @inv_pro.inventory_batches.each do |inventory_batch|
          inventory_batch.grn_batches.each do |grn_batch|
            rem = grn_batch.remaining_quantity
            cost = grn_batch.grn_item.current_unit_cost
            tot_cost = rem*cost
            @ans = @ans + tot_cost
          end
        end

        render "admins/searches/inventory/select_batches"

      when "select_non_serial_or_batch"
        @store = params[:store]
        @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?  
        @inventory_non_serial_non_batches = Kaminari.paginate_array(@inv_pro.grn_items).page(params[:page]).per(10)
        tot_cost = 0
        @ans = 0
        @inv_pro.grn_items.each do |inventory_non_serial_non_batch|
          cost = inventory_non_serial_non_batch.current_unit_cost
          qnty = inventory_non_serial_non_batch.remaining_quantity
          tot_cost = cost*qnty
          @ans = @ans + tot_cost
        end

        render "admins/searches/inventory/select_non_serial_or_batch"

      when "select_inventory_batch_more"
        @store = params[:store]
        @inventory_batch_id = InventoryBatch.find params[:inventory_batch_id] if params[:inventory_batch_id].present?

        render "admins/searches/inventory/select_inventory_batch_more"
      when "select_non_serial_or_batch_more"
        @store = params[:store]
        @inventory_non_serial_non_batch_id = InventorySerialPart.find params[:inventory_non_serial_non_batch_id] if params[:inventory_non_serial_non_batch_id].present?
        render "admins/searches/inventory/select_non_serial_or_batch_more"
      else
        render "admins/searches/inventory/inventories"
      end
    end

    def delete_inv_sitem_additional_cost
      Inventory
      @store = params[:store]
      @inventory_serial_item_id = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
      @ad_cost_id = InventorySerialItemsAdditionalCost.find_by_id params[:ad_cost_id]
      if @ad_cost_id.present?
        @ad_cost_id.delete
      end
      @inventory_serial_item_add_cost = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_items_additional_costs).page(params[:page]).per(10)
      @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
      render "admins/searches/inventory/select_serial_item_more"
    end

    def action_inv_serial_item_addcost
      Inventory
      @store = params[:store]
      @inventory_serial_item_id = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
      if params[:load]
        @inv_sitem_addcost = InventorySerialItemsAdditionalCost.find params[:ad_cost_id]
      end
      if params[:edit]
        @inv_sitem_addcost = InventorySerialItemsAdditionalCost.find params[:ad_cost_id]
        if @inv_sitem_addcost.update inv_sitem_addcost_update_params
          @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new
        end
      end
      if params[:new_add]
        @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new
      end
      @inventory_serial_item_add_cost = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_items_additional_costs).page(params[:page]).per(10)
      @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
      render "admins/searches/inventory/select_serial_item_more"
    end

    def create_new_inv_sitem_addcost
      Inventory
      @store = params[:store]
      @inventory_serial_item_id = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
      @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new inv_sitem_addcost_params
      @inv_sitem_addcost.save
      @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new
      @inventory_serial_item_add_cost = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_items_additional_costs).page(params[:page]).per(10)
      @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
      render "admins/searches/inventory/select_serial_item_more"
    end

    def delete_inv_sitem_part_additional_cost
      Inventory
      @store = params[:store]
      @inventory_serial_item_part_id = InventorySerialPart.find params[:inventory_serial_item_part_id] if params[:inventory_serial_item_part_id].present?
      @ad_cost_id = InventorySerialPartAdditionalCost.find_by_id params[:ad_cost_id]
      if @ad_cost_id.present?
        @ad_cost_id.delete
      end
      @inventory_serial_item_part_add_cost = Kaminari.paginate_array(@inventory_serial_item_part_id.inventory_serial_part_additional_costs).page(params[:page]).per(10)
      render "admins/searches/inventory/select_inventory_serial_part_more"
    end

    def action_inv_serial_item_part_addcost
      Inventory
      @store = params[:store]
      @inventory_serial_item_part_id = InventorySerialPart.find params[:inventory_serial_item_part_id] if params[:inventory_serial_item_part_id].present?
      if params[:load]
        @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.find params[:ad_cost_id]
      end
      if params[:edit]
        @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.find params[:ad_cost_id]
        if @inv_sitem_part_addcost.update inv_sitem_part_addcost_update_params
          @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.new
        end
      end
      if params[:new_add]
        @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.new
      end
      @inventory_serial_item_part_add_cost = Kaminari.paginate_array(@inventory_serial_item_part_id.inventory_serial_part_additional_costs).page(params[:page]).per(10)
      render "admins/searches/inventory/select_inventory_serial_part_more"
    end

    def create_new_inv_sitem_part_addcost
      Inventory
      @store = params[:store]
      @inventory_serial_item_part_id = InventorySerialPart.find params[:inventory_serial_item_part_id] if params[:inventory_serial_item_part_id].present?
      @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.new inv_sitem_part_addcost_params
      @inv_sitem_part_addcost.save
      @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.new
      @inventory_serial_item_part_add_cost = Kaminari.paginate_array(@inventory_serial_item_part_id.inventory_serial_part_additional_costs).page(params[:page]).per(10)
      render "admins/searches/inventory/select_inventory_serial_part_more"
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