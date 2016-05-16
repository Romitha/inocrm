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
        format.html { redirect_to organization_regional_support_center_admins_organizations_path }
      end
    end

    def delete_sbu_regional_engineer
      User
      @rs_engineer = SbuRegionalEngineer.find params[:sbu_regional_engineer_id]
      if @rs_engineer.present?
        @rs_engineer.delete
      end
      respond_to do |format|
        format.html { redirect_to organization_regional_support_center_admins_organizations_path }
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

    private
      def regional_support_center_params
        params.require(:regional_support_center).permit(:organization_id, :active, sbu_regional_engineers_attributes: [:engineer_id])
      end

      def sburegional_engineer_params
        params.require(:sbu_regional_engineer).permit(:engineer_id)
      end
  end
end