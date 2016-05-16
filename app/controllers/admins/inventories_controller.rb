module Admins
  class InventoriesController < ApplicationController
    layout "admins"

    def index

    end

    def grn
      Inventory
      Grn

      case params[:purchase_order]
      when "yes"
        @stores = Organization.stores
        @render_template = "select_po"
      when "no"
        @render_template = "select_inventory"

      when "select_inventory"
        
      when "search_po"
        @pos = InventoryPo.where(closed: false).where("po_no = :po_no or store_id = :store_id or supplier_id = :supplier_id", params[:po])
        if params[:po_date_from].to_date and params[:po_date_to].to_date
          @pos = @pos.where(created_at: (params[:po_date_from]..params[:po_date_to]))
        end

        Rails.cache.delete([:po_item_ids])
        @render_template = "search_po"

      when "select_po"
        @po = InventoryPo.find params[:po_id]

        @render_template = "new_grn"

      when "select_po_item"
        @po_item = InventoryPoItem.find params[:po_item_id]

        @grn_item = Rails.cache.fetch([:grn_item, params[:po_item_id].to_i ]) { GrnItem.new }

        @render_template = "grn_item"        
      end

      render "admins/inventories/grn/grn"
    end

    def initialize_grn
      Inventory
      Grn
      @po_item = InventoryPoItem.find params[:po_item_id]

      @grn_item = GrnItem.new grn_item_params

      if params[:next].present?
        if @grn_item.valid?
          if not Rails.cache.fetch([:po_item_ids]).to_a.include? params[:po_item_id].to_i
            a = Rails.cache.fetch([:po_item_ids]).to_a
            a << params[:po_item_id].to_i
            Rails.cache.write([:po_item_ids], a)
          end
          Rails.cache.write([:grn_item, @po_item.id], @grn_item )

          if Rails.cache.fetch([:po_item_ids]).to_a.count == @po_item.inventory_po.inventory_po_items.count
            @grn = Grn.new #(po_id: @po.id, grn_no: CompanyConfig.first.next_sup_last_grn_no, store_id: @po.store_id)

          end
        else
          a = Rails.cache.fetch([:po_item_ids]).to_a
          a.delete(params[:po_item_id].to_i)
          Rails.cache.write([:po_item_ids], a)
        end
      elsif params[:cancel]
        Rails.cache.delete([:grn_item, @po_item.id] )
      end

      if @po_item.valid?
        render "admins/inventories/grn/grn"
      end

    end

    def create_grn
      Inventory
      Organization
      @grn = Grn.new grn_params
      @grn.store_id = 1
      @grn.created_at = DateTime.now
      @grn.created_by = current_user.id
      @grn.grn_no = CompanyConfig.first.next_sup_last_grn_no
      @grn.save!

      Rails.cache.fetch([:po_item_ids]).to_a.each do | po_item_id |
        po_item = InventoryPoItem.find po_item_id
        grn_item = Rails.cache.fetch([:grn_item, po_item_id ] )

        grn_item.grn_id = @grn.id
        grn_item.po_item_id = po_item.id
        grn_item.product_id = po_item.inventory_prn_item.product_id
        grn_item.remaining_quantity = 0
        grn_item.recieved_quantity = 0
        grn_item.unit_cost = po_item.unit_cost
        grn_item.unit_cost = po_item.unit_cost
        grn_item.current_unit_cost = po_item.unit_cost
        grn_item.currency_id = po_item.inventory_po.currency_id
        grn_item.save!

        po_item.update closed: (po_item.quantity.to_f <= po_item.grn_items.sum(:recieved_quantity).to_f )
        Rails.cache.delete([:grn_item, po_item_id] )

      end
      flash[:notice] = "Successfully saved."

      Rails.cache.delete([:po_item_ids])

      redirect_to grn_admins_inventories_url

    end

    private
      def inventory_po_item_params
        params.require(:inventory_po_item).permit(:id, grn_items_attributes: [:recieved_quantity, :remarks, grn_batches_attributes: [:id, :recieved_quantity, :_destroy, inventory_batch_attributes: [:id, :_destroy, :lot_no, :batch_no, :manufatured_date, :expiry_date, :remarks, ]], grn_serial_items_attributes: [:id, :_destroy, :recieved_quantity, inventory_serial_item_attributes: [:id, :_destroy, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]]]]])
      end

      def grn_item_params
        params.require(:grn_item).permit(:id, :recieved_quantity, :remarks, grn_batches_attributes: [:id, :recieved_quantity, :remaining_quantity, :_destroy, inventory_batch_attributes: [:id, :_destroy, :inventory_id, :product_id, :created_by, :lot_no, :batch_no, :manufatured_date, :expiry_date, :remarks, ]], grn_serial_items_attributes: [:id, :_destroy, :recieved_quantity, inventory_serial_item_attributes: [:id, :_destroy, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]]]])
      end

      def grn_params
        params.require(:grn).permit(:remarks)
      end

  end
end