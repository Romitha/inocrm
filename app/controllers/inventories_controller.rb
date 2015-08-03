class InventoriesController < ApplicationController

  def inventory_in_modal
    Inventory
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
        # parent_query
      end
      format.js {render :inventory_in_modal}
      # format.js {render js: "alert('#{parent_query}');"}
    end
  end
end
