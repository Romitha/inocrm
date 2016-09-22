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

    def inv_searched_by
      Inventory
      User
      @remote = true
      @inv_searched_by = true
      @store = Organization.find params[:store_id] if params[:store_id].present?

      case params[:select_action]

      #+++++++++++++++++++++++++++++recreating code again+++++++++++++++++++
      when "select_serial_items"
        @store = params[:store]
        @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?
        @inventory_serial_items = Kaminari.paginate_array(@inv_pro.inventory_serial_items).page(params[:page]).per(10)
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


      #+++++++++++++++++++old select serial item code+++++++++++++++++++++++++++=

      # when "select_serial_items"
      #   @store = params[:store]
      #   @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?
      #   @inventory_serial_items = Kaminari.paginate_array(@inv_pro.inventory_serial_items).page(params[:page]).per(10)
      #   render "admins/searches/inventory/select_serial_items"

      #   # @inv_pro = InventoryProduct.find params[:inv_pro_id]
      #   # @serial_items = Kaminari.paginate_array(@inv_pro.inventory_serial_items).page(params[:page]).per(10)

      #   # render "admins/searches/inventory/select_serial_items"

      #   # *********


      #   # refined_search_query = params[:search_inventory].except('inventory_product').map{|k, v| "#{k}:#{v}" if k.present? and v.present? }.compact.join(" AND ")
      #   # refined_inventory_product = params[:search_inventory][:inventory_product].map { |k, v| "inventory_product.#{k}:#{v}" if v.present? }.compact.join(" AND ")
      #   # refined_inventory_serial_items = params[:search_inventory].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

      #   # refined_search = ["inventory_product.id:#{params[:inv_pro_id]}"].map{|v| v if v.present? }.compact.join(" AND ")
      #   # params[:query] = refined_search

      #    #InventorySerialItem.search(params)

      #   # *********


      # ++++++++++++++++mistakenly deleted form++++++++++++++++++++++++++++++++++++
      # when "select_serial_item_more"
      #   @store = params[:store]
      #   @inventory_serial_item_id = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
      #   @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
      #   @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new
      #   # if params[:create]
      #   #   @action = "create"
      #   # end
      #   render "admins/searches/inventory/select_serial_item_more"
      #   # when "delete_inv_sitem_additional_cost"
      #   #   @ad_cost_id = InventorySerialItemsAdditionalCost.find params[:ad_cost_id]
      #   #   if @ad_cost_id.present?
      #   #     @ad_cost_id.delete
      #   #   end
      #   #   render "admins/searches/inventory/select_serial_item_more"


      when "select_batches"
        @store = params[:store]
        @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?
        if @inv_pro.inventory_batches.present?
          @inventory_batches = Kaminari.paginate_array(@inv_pro.inventory_batches).page(params[:page]).per(10)
        end
        # @inventory_batches = @inv_pro.grn_batches
        render "admins/searches/inventory/select_batches"

        # refined_search = ["inventory_product.id:#{params[:inv_pro_id]}"].map{|v| v if v.present? }.compact.join(" AND ")
        # params[:query] = refined_search
        # @inventory_batches = @inv_pro.grn_batches # InventoryBatch.search(params)


      when "select_non_serial_or_batch"
        @store = params[:store]
        @inv_pro = InventoryProduct.find params[:inv_pro_id] if params[:inv_pro_id].present?
        if @inv_pro.grn_items.present?
          @inventory_non_serial_non_batches = Kaminari.paginate_array(@inv_pro.grn_items).page(params[:page]).per(10)
        end
        render "admins/searches/inventory/select_non_serial_or_batch"

      when "select_inventory_batch_more"
        @store = params[:store]
        @inventory_batch_id = InventoryBatch.find params[:inventory_batch_id] if params[:inventory_batch_id].present?
        # @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new

        render "admins/searches/inventory/select_inventory_batch_more"
      when "select_non_serial_or_batch_more"
        @store = params[:store]
        @inventory_non_serial_non_batch_id = InventorySerialPart.find params[:inventory_non_serial_non_batch_id] if params[:inventory_non_serial_non_batch_id].present?


        # @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new

        render "admins/searches/inventory/select_non_serial_or_batch_more"
      else
        render "admins/searches/inventory/inv_searched_by"
      end
      # case params[:inv_searched_by_param]
      # when "inv_search_result"
      #   @inventories = Inventory.search(params)
      #   @store_id = params[:store_id]
      #   render "admins/searches/inventory/searched_result"
      # else

    end

    def delete_inv_sitem_additional_cost
      Inventory
      @store = params[:store]
      @inventory_serial_item_id = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
      @ad_cost_id = InventorySerialItemsAdditionalCost.find_by_id params[:ad_cost_id]
      if @ad_cost_id.present?
        @ad_cost_id.delete
      end
      # @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new

      if @inventory_serial_item_id.inventory_serial_items_additional_costs.present?
        @inventory_serial_item_add_cost = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_items_additional_costs).page(params[:page]).per(10)
      end
      if @inventory_serial_item_id.inventory_serial_parts
       @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
      end

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

      if @inventory_serial_item_id.inventory_serial_items_additional_costs.present?
        @inventory_serial_item_add_cost = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_items_additional_costs).page(params[:page]).per(10)
      end
      if @inventory_serial_item_id.inventory_serial_parts
       @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
      end

      render "admins/searches/inventory/select_serial_item_more"
    end

    def create_new_inv_sitem_addcost
      Inventory
      @store = params[:store]
      @inventory_serial_item_id = InventorySerialItem.find params[:inventory_serial_item_id] if params[:inventory_serial_item_id].present?
      @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new inv_sitem_addcost_params
      if @inv_sitem_addcost.save
        # params[:create] = nil
      end
      @inv_sitem_addcost = InventorySerialItemsAdditionalCost.new


      if @inventory_serial_item_id.inventory_serial_items_additional_costs.present?
        @inventory_serial_item_add_cost = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_items_additional_costs).page(params[:page]).per(10)
      end
      if @inventory_serial_item_id.inventory_serial_parts
       @inventory_serial_parts = Kaminari.paginate_array(@inventory_serial_item_id.inventory_serial_parts).page(params[:page]).per(10)
      end

      render "admins/searches/inventory/select_serial_item_more"
    end



    #==============================for parts===================







    def delete_inv_sitem_part_additional_cost
      Inventory
      @store = params[:store]
      @inventory_serial_item_part_id = InventorySerialPart.find params[:inventory_serial_item_part_id] if params[:inventory_serial_item_part_id].present?
      @ad_cost_id = InventorySerialPartAdditionalCost.find_by_id params[:ad_cost_id]
      if @ad_cost_id.present?
        @ad_cost_id.delete
      end
      # @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.new

      if @inventory_serial_item_part_id.inventory_serial_part_additional_costs.present?
        @inventory_serial_item_part_add_cost = Kaminari.paginate_array(@inventory_serial_item_part_id.inventory_serial_part_additional_costs).page(params[:page]).per(10)
      end
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

      if @inventory_serial_item_part_id.inventory_serial_part_additional_costs.present?
        @inventory_serial_item_part_add_cost = Kaminari.paginate_array(@inventory_serial_item_part_id.inventory_serial_part_additional_costs).page(params[:page]).per(10)
      end


      render "admins/searches/inventory/select_inventory_serial_part_more"
    end

    def create_new_inv_sitem_part_addcost
      Inventory
      @store = params[:store]
      @inventory_serial_item_part_id = InventorySerialPart.find params[:inventory_serial_item_part_id] if params[:inventory_serial_item_part_id].present?
      @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.new inv_sitem_part_addcost_params
      if @inv_sitem_part_addcost.save
        # params[:create] = nil
      end
      @inv_sitem_part_addcost = InventorySerialPartAdditionalCost.new


      if @inventory_serial_item_part_id.inventory_serial_part_additional_costs.present?
        @inventory_serial_item_part_add_cost = Kaminari.paginate_array(@inventory_serial_item_part_id.inventory_serial_part_additional_costs).page(params[:page]).per(10)
      end

      render "admins/searches/inventory/select_inventory_serial_part_more"
    end

    #===================================================================

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

      # #================================for parts






      # def inv_sitem_part_addcost_params
      #   params.require(:inventory_serial_part_additional_costs).permit(:id, :serial_item_id, :cost, :currency_id, :note, :created_by, :created_at)
      # end

      # def inv_sitem_part_addcost_update_params
      #   params.require(:inventory_serial_part_additional_costs).permit(:cost, :note)
      # end





      # #=====================
  end
end