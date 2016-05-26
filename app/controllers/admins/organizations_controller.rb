module Admins
  class OrganizationsController < ApplicationController
    layout "admins"

    def index
      
    end

    def delete_admin_regional_support_center
      User
      @rs_center = RegionalSupportCenter.find params[:regional_support_center_id]
      if @rs_center.present?
        @rs_center.delete
      end
      respond_to do |format|
        format.html { redirect_to regional_support_center_admins_organizations_path }
      end
    end

    def delete_sbu_regional_engineer
      User
      @rs_engineer = SbuRegionalEngineer.find params[:sbu_regional_engineer_id]
      if @rs_engineer.present?
        @rs_engineer.delete
      end
      respond_to do |format|
        format.html { redirect_to regional_support_center_admins_organizations_path }
      end
    end

    def regional_support_center
      TaskAction
      User
      Organization

      if params[:edit]
        if params[:regional_support_center_id]
          @regional_support_center = RegionalSupportCenter.find params[:regional_support_center_id]
          if @regional_support_center.update regional_support_center_params
            params[:edit] = nil
            render json: @regional_support_center
          end
        elsif params[:sbu_regional_engineer_id]
          @sbu_regional_engineer = SbuRegionalEngineer.find params[:sbu_regional_engineer_id]
          if @sbu_regional_engineer.update sburegional_engineer_params
            params[:edit] = nil
            render json: @sbu_regional_engineer
          end
        end
      else
        if params[:create]
          @regional_support_center = RegionalSupportCenter.new regional_support_center_params
          if @regional_support_center.save
            params[:create] = nil
            @regional_support_center = RegionalSupportCenter.new
          end
        else
          @regional_support_center = RegionalSupportCenter.new
        end
        @regional_support_center_all = RegionalSupportCenter.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/organizations/regional_support_center"
      end
    end

    def country
      Ticket
      Product
      if params[:edit]
        @admin_country = ProductSoldCountry.find params[:country_id]
        if @admin_country.update admin_country_params
          params[:edit] = nil
          render json: @admin_country

        end
      else
        if params[:create]
          @country = ProductSoldCountry.new admin_country_params
          if @country.save
            params[:create] = nil
            @country = ProductSoldCountry.new
          end
        else
          @country = ProductSoldCountry.new
        end
        @country_all = ProductSoldCountry.order(created_at: :desc).select{|i| i.persisted? }
        # render "admins/tickets/country"
      end

    end

    def delete_admin_country
      Ticket
      Product
      @admin_country = ProductSoldCountry.find params[:country_id]
      if @admin_country.present?
        @admin_country.delete
      end
      respond_to do |format|
        format.html { redirect_to country_admins_organizations_path}
      end
    end

    def sla
      SlaTime
      if params[:edit]
        @sla = SlaTime.find params[:sla_id]
        if @sla.update sla_params
          params[:edit] = nil
          render json: @sla
        end
      else
        if params[:create]
          @sla = SlaTime.new sla_params
          if @sla.save
            params[:create] = nil
            @sla = SlaTime.new
          end
        else
          @sla = SlaTime.new
        end
        @sla_all = SlaTime.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    private
      def regional_support_center_params
        params.require(:regional_support_center).permit(:organization_id, :active, sbu_regional_engineers_attributes: [:engineer_id])
      end

      def admin_country_params
        params.require(:product_sold_country).permit(:Country, :code)
      end

      def sla_params
        params.require(:sla_time).permit(:sla_time, :description, :created_by)
      end

      def sburegional_engineer_params
        params.require(:sbu_regional_engineer).permit(:engineer_id)
      end
  end
end