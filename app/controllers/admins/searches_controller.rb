module Admins
  class SearchesController < ApplicationController
    layout "admins"

    def update_grn_cost
      Inventory
      User
      Grn
      @update_grn_item = GrnItem.find params[:grnitem_id]
      @update_grn_item.update update_grn_item_params
      @grnitem = GrnItem.find params[:grnitem_id]
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

    private
      def update_grn_item_params
        params.require(:grn_item).permit(:remarks, grn_item_current_unit_cost_histories_attributes: [:id, :current_unit_cost, :created_by, :created_at])
      end
  end
end