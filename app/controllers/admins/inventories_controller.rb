module Admins
  class InventoriesController < ApplicationController
    layout "admins"

    def index
    end

    def delete_admin_payment_item
      TaskAction
      @payment_itemn = PaymentItem.find params[:payment_item_id]
      if @payment_itemn.present?
        @payment_itemn.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_payment_item_admins_inventories_path }
      end
    end

    def delete_admin_brands_and_category
      Product
      @brands_and_category = ProductBrand.find params[:brands_and_category_id]
      if @brands_and_category.present?
        @brands_and_category.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_brands_and_category_admins_inventories_path }
      end
    end

    def delete_product_category
      Product
      @product_category = ProductCategory.find params[:product_category_id]
      if @product_category.present?
        @product_category.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_brands_and_category_admins_inventories_path }
      end
    end

    def delete_problem_category
      @problem_category = ProblemCategory.find params[:problem_category_id]
      if @problem_category.present?
        @problem_category.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_problem_and_category_admins_inventories_path }
      end
    end

    def delete_q_and_a
      @q_and_a = QAndA.find params[:q_and_a_id]
      if @q_and_a.present?
        @q_and_a.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_problem_and_category_admins_inventories_path }
      end
    end

    def delete_location_rack
      Inventory
      @delete_rack = InventoryRack.find params[:rack_id]
      if @delete_rack.present?
        @delete_rack.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_location_admins_inventories_path }
      end
    end

    def delete_location_shelf
      Inventory
      @delete_shelf = InventoryShelf.find params[:shelf_id]
      if @delete_shelf.present?
        @delete_shelf.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_location_admins_inventories_path }
      end
    end

    def delete_location_bin
      Inventory
      @delete_bin = InventoryBin.find params[:bin_id]
      if @delete_bin.present?
        @delete_bin.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_location_admins_inventories_path }
      end
    end

    def delete_inventory_brand
      Inventory
      @delete_brand = InventoryCategory1.find params[:brand_id]
      if @delete_brand.present?
        @delete_brand.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_category_admins_inventories_path }
      end
    end

    def delete_inventory_product
      Inventory
      @delete_product = InventoryCategory2.find params[:product_id]
      if @delete_product.present?
        @delete_product.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_category_admins_inventories_path }
      end
    end

    def delete_inventory_category
      Inventory
      @delete_category = InventoryCategory3.find params[:category_id]
      if @delete_category.present?
        @delete_category.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_category_admins_inventories_path }
      end
    end

    def delete_product_condition
      Inventory
      @inventory_product_condition = ProductCondition.find params[:product_condition_id]
      if @inventory_product_condition.present?
        @inventory_product_condition.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_product_condition_admins_inventories_path }
      end
    end

    def delete_disposal_method
      Inventory
      @inventory_disposal_method = InventoryDisposalMethod.find params[:disposal_id]
      if @inventory_disposal_method.present?
        @inventory_disposal_method.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_disposal_method_admins_inventories_path }
      end
    end

    def delete_admin_inventory_reason
      @inventory_reason = InventoryReason.find params[:inventory_reason_id]
      if @inventory_reason.present?
        @inventory_reason.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_reason_admins_inventories_path }
      end
    end

    def delete_inventory_manufacture
      Inventory
      @delete_manufacture = Manufacture.find params[:manufacture_id]
      if @delete_manufacture.present?
        @delete_manufacture.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_manufacture_admins_inventories_path }
      end
    end

    def delete_inventory_unit
      Inventory
      @inventory_unit = InventoryUnit.find params[:unit_id]
      if @inventory_unit.present?
        @inventory_unit.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_unit_admins_inventories_path }
      end
    end

    def payment_item
      TaskAction

      if params[:edit]
        @payment_item = PaymentItem.find params[:payment_item_id]
        if @payment_item.update admin_payment_item_params
          params[:edit] = nil
          render json: @payment_item
        end
      else
        if params[:create]
          @payment_item = PaymentItem.new admin_payment_item_params
          if @payment_item.save
            params[:create] = nil
            @payment_item = PaymentItem.new
          end
        else
          @payment_item = PaymentItem.new
        end
        @payment_item_all = PaymentItem.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/payment_item"
      end
    end

    def brands_and_category
      Product
      SlaTime
      Organization
      Currency

      if params[:edit]

        if params[:brands_and_category_id]
          @brands_and_category = ProductBrand.find params[:brands_and_category_id]
          if @brands_and_category.update brands_and_category_params
            params[:edit] = nil
            render json: @brands_and_category
          end
        elsif params[:product_category_id]
          @product_category = ProductCategory.find params[:product_category_id]
          if @product_category.update product_category_params
            params[:edit] = nil
            render json: @product_category
          end
        end

      else
        if params[:create]
          @brands_and_category = ProductBrand.new brands_and_category_params
          if @brands_and_category.save
            params[:create] = nil
            @brands_and_category = ProductBrand.new
          else
            flash[:error] = "Unable to save"
          end
        else
          @brands_and_category = ProductBrand.new
        end
        @brands_and_category_all = ProductBrand.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/brands_and_category"
      end
    end

    def problem_and_category
      Ticket
      TaskAction
      Product
      if params[:edit]
        if params[:problem_category_id]
          @problem_category = ProblemCategory.find params[:problem_category_id]
          if @problem_category.update problem_category_params
            params[:edit] = nil
            render json: @problem_category
          end
        elsif params[:q_and_a_id]
          @q_and_a = QAndA.find params[:q_and_a_id]
          if @q_and_a.update q_and_a_params
            params[:edit] = nil
            render json: @q_and_a
          end
        end
      else
        if params[:create]
          @problem_category = ProblemCategory.new problem_category_params
          if @problem_category.save
            params[:create] = nil
            @problem_category = ProblemCategory.new
          end
        else
          @problem_category = ProblemCategory.new
        end
        @problem_category_all = ProblemCategory.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/problem_and_category"
      end
    end

    def location
      Inventory
      Product
      if params[:edit]
        if params[:rack_id]
          @inventory_rack = InventoryRack.find params[:rack_id]
          if @inventory_rack.update inventory_rack_params
            params[:edit] = nil
            render json: @inventory_rack
          end
        elsif params[:shelf_id]
          @inventory_shelf = InventoryShelf.find params[:shelf_id]
          if @inventory_shelf.update inventory_shelf_params
            params[:edit] = nil
            render json: @inventory_shelf
          end
        elsif params[:bin_id]
          @inventory_bin = InventoryBin.find params[:bin_id]
          if @inventory_bin.update inventory_bin_params
            params[:edit] = nil
            render json: @inventory_bin
          end
        end

      else
        if params[:create]
          @inventory_rack = InventoryRack.new inventory_rack_params
          if @inventory_rack.save
            params[:create] = nil
            @inventory_rack = InventoryRack.new
          end
        else
          @inventory_rack = InventoryRack.new
        end
        @inventory_all_rack = InventoryRack.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/location"
      end
    end

    def category
      Inventory
      if params[:edit]

        if params[:brand_id]
          @inventory_brand = InventoryCategory1.find params[:brand_id]
          if @inventory_brand.update inventory_brand_params
            params[:edit] = nil
            render json: @inventory_brand
          end
        elsif params[:product_id]
          @inventory_product = InventoryCategory2.find params[:product_id]
          if @inventory_product.update inventory_category2_params
            params[:edit] = nil
            render json: @inventory_product
          end
        elsif params[:category_id]
          @inventory_category = InventoryCategory3.find params[:category_id]
          if @inventory_category.update inventory_category_params
            params[:edit] = nil
            render json: @inventory_category
          end
        end

      else
        if params[:create]
          @inventory_category1 = InventoryCategory1.new inventory_brand_params
          if @inventory_category1.save
            params[:create] = nil
            @inventory_category1 = InventoryCategory1.new
          end
        else
          @inventory_category1 = InventoryCategory1.new
        end
        @inventory_category1_all = InventoryCategory1.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/category"
      end
    end

    def product
      Inventory
      Product
      Currency
      InventorySerialItem
      if params[:edit]
        if params[:product_id]
          @inventory_product_form = InventoryProduct.find params[:product_id]
          if @inventory_product_form.update inventory_product_params
            params[:edit] = nil
            render json: @inventory_product_form
          end
        elsif params[:product_info_id]
          @inventory_product1 = InventoryProductInfo.find params[:product_id]
          if @inventory_product1.update inventory_product_info_params
            params[:edit] = nil
            render json: @inventory_product
          end
        end

      else
        if params[:create]
          @inventory_product = InventoryProduct.new inventory_product_params
          if @inventory_product.save
            params[:create] = nil
            @inventory_product = InventoryProduct.new
          end
        else
          @inventory_product = InventoryProduct.new
        end
        @inventory_product_all = InventoryProduct.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/product"
      end
    end

    def product_condition
      Inventory
      if params[:edit]
        @inventory_product_condition = ProductCondition.find params[:product_condition_id]
        if @inventory_product_condition.update inventory_product_condition_params
          params[:edit] = nil
          render json: @inventory_product_condition
        end

      else
        if params[:create]
          @inventory_product_condition = ProductCondition.new inventory_product_condition_params
          if @inventory_product_condition.save
            params[:create] = nil
            @inventory_product_condition = ProductCondition.new
          end
        else
          @inventory_product_condition = ProductCondition.new
        end
        @inventory_product_condition_all = ProductCondition.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/product_condition"
      end
    end

    def disposal_method
      Inventory
      if params[:edit]
        @inventory_disposal_method = InventoryDisposalMethod.find params[:disposal_method]
        if @inventory_disposal_method.update inventory_disposal_method_params
          params[:edit] = nil
          render json: @inventory_disposal_method
        end

      else
        if params[:create]
          @inventory_disposal_method = InventoryDisposalMethod.new inventory_disposal_method_params
          if @inventory_disposal_method.save
            params[:create] = nil
            @inventory_disposal_method = InventoryDisposalMethod.new
          end
        else
          @inventory_disposal_method = InventoryDisposalMethod.new
        end
        @inventory_disposal_method_all = InventoryDisposalMethod.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/disposal_method"
      end
    end

    def reason
      Inventory
      if params[:edit]
        @inventory_reason = InventoryReason.find params[:inventory_reason_id]
        if @inventory_reason.update inventory_reason_params
          params[:edit] = nil
          render json: @inventory_reason
        end

      else
        if params[:create]
          @inventory_reason = InventoryReason.new inventory_reason_params
          if @inventory_reason.save
            params[:create] = nil
            @inventory_reason = InventoryReason.new
          end
        else
          @inventory_reason = InventoryReason.new
        end
        @inventory_reason_all = InventoryReason.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/reason"
      end
    end

    def manufacture
      Inventory
      if params[:edit]
        @inventory_manufacture = Manufacture.find params[:manufacture_id]
        if @inventory_manufacture.update inventory_manufacture_params
          params[:edit] = nil
          render json: @inventory_manufacture
        end

      else
        if params[:create]
          @inventory_manufacture = Manufacture.new inventory_manufacture_params
          if @inventory_manufacture.save
            params[:create] = nil
            @inventory_manufacture = Manufacture.new
          end
        else
          @inventory_manufacture = Manufacture.new
        end
        @inventory_manufacture_all = Manufacture.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/manufacture"
      end
    end

    def unit
      Inventory
      if params[:edit]
        @inventory_unit = InventoryUnit.find params[:unit_id]
        if @inventory_unit.update inventory_unit_params
          params[:edit] = nil
          render json: @inventory_unit
        end

      else
        if params[:create]
          @inventory_unit = InventoryUnit.new inventory_unit_params
          if @inventory_unit.save
            params[:create] = nil
            @inventory_unit = InventoryUnit.new
          end
        else
          @inventory_unit = InventoryUnit.new
        end
        @inventory_unit_all = InventoryUnit.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/inventories/unit"
      end

    end

    private
      def admin_payment_item_params
        params.require(:payment_item).permit(:name, :default_amount)
      end

      def brands_and_category_params
        params.require(:product_brand).permit(:name, :sla_id, :organization_id, :parts_return_days, :warranty_date_format, :currency_id, product_categories_attributes: [:id, :_destroy, :name, :sla_id])
      end

      def product_category_params
        params.require(:product_category).permit(:name, :sla_id)
      end

      def problem_category_params
        params.require(:problem_category).permit(:name ,q_and_as_attributes: [:_destroy, :id, :question, :answer_type, :active, :action_id, :compulsory])
      end

      def q_and_a_params
        params.require(:inventory_shelf).permit(:description)
      end

      def inventory_rack_params
        params.require(:inventory_rack).permit(:description, :location_id, :aisle_image, :created_by, :updated_by,inventory_shelfs_attributes: [:_destroy, :id, :description, :created_by, :updated_by, inventory_bins_attributes: [:_destroy, :id, :description, :created_by, :updated_by]])
      end

      def inventory_shelf_params
        params.require(:inventory_shelf).permit(:description)
      end

      def inventory_bin_params
        params.require(:inventory_bin).permit(:description)
      end

      def inventory_brand_params
        params.require(:inventory_category1).permit(:code, :name, :created_by, :created_by, inventory_category2s_attributes: [:_destroy, :id, :code, :name, :created_by, :updated_by, inventory_category3s_attributes: [:_destroy, :id, :code, :name, :created_by, :updated_by] ])
      end

      def inventory_category2_params
        params.require(:inventory_category2).permit(:code, :name)
      end

      def inventory_category_params
        params.require(:inventory_category3).permit(:code, :name)
      end

      def inventory_product_params
        params.require(:inventory_product).permit(:category3_id, :serial_no, :serial_no_order, :sku, :legacy_code, :description, :model_no, :product_no, :spare_part_no, :fifo, :active, :spare_part, :unit_id, :created_by, :updated_by, :non_stock_item, inventory_product_info_attributes: [:picture, :secondary_unit_id, :issue_fractional_allowed, :per_secondery_unit_conversion, :need_serial, :need_batch, :country_id, :manufacture_id, :average_cost, :standard_cost, :currency_id, :remarks])
      end

      def inventory_product_info_params
        params.require(:inventory_product_info).permit(:secondary_unit_id, :average_cost, :need_serial, :need_batch, :per_secondery_unit_conversion, :country_id, :manufacture_id, :currency_id, :standard_cost,:average_cost)
      end

      def inventory_product_condition_params
        params.require(:product_condition).permit(:condition, :created_by, :updated_by)
      end

      def inventory_disposal_method_params
        params.require(:inventory_disposal_method).permit(:disposal_method, :created_by, :updated_by)
      end

      def inventory_reason_params
        params.require(:inventory_reason).permit(:srn_issue_terminate, :damage, :srr, :disposal, :reason, :created_by, :updated_by)
      end

      def inventory_manufacture_params
        params.require(:manufacture).permit(:manufacture, :created_by, :created_by)
      end

      def inventory_unit_params
        params.require(:inventory_unit).permit(:unit, :base_unit_id, :base_unit_conversion, :per_base_unit, :description, :created_by, :created_by)
      end
  end
end