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

  private
    def ticket_spare_part_params
      t_spare_part = params.require(:ticket_spare_part).permit(:spare_part_no, :spare_part_description, :ticket_id, :ticket_fsr, :cus_chargeable_part, :request_from, :faulty_serial_no, :faulty_ct_no, :note, :status_action_id, :status_use_id, ticket_attributes: [:remarks, :id])
      t_spare_part[:note] = t_spare_part[:note].present? ? "#{t_spare_part[:note]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket_spare_part.note}" : @ticket_spare_part.note

      t_spare_part
    end
end