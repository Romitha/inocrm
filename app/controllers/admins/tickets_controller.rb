module Admins
  class TicketsController < ApplicationController
    layout "admins"

    def index
      Ticket
      @ticket_statuses = TicketStatus.all
    end

    def delete_admin_reason
      Ticket
      @mst_reason = Reason.find params[:mst_reason_id]
      if @mst_reason.present?
        @mst_reason.delete
      end
      respond_to do |format|
        format.html { redirect_to ticket_reason_admins_tickets_path }
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
        format.html { redirect_to ticket_country_admins_tickets_path}
      end
    end

    def delete_admin_accessory
      Ticket
      Product
      @admin_accessory = Accessory.find params[:accessory_id]
      if @admin_accessory.present?
        @admin_accessory.delete
      end
      respond_to do |format|
        format.html { redirect_to ticket_accessories_admins_tickets_path}
      end
    end

    def delete_admin_additional_charge
      TicketEstimation
      @add_charge = AdditionalCharge.find params[:add_charge_id]
      if @add_charge.present?
        @add_charge.delete
      end
      respond_to do |format|
        format.html { redirect_to ticket_additional_charge_admins_tickets_path }
      end
    end

    def delete_admin_spare_part_description
      TicketSparePart
      @sp_description = SparePartDescription.find params[:sp_description_id]
      if @sp_description.present?
        @sp_description.delete
      end
      respond_to do |format|
        format.html { redirect_to ticket_spare_part_description_admins_tickets_path }
      end
    end

    def delete_admin_ticket_start_action
      Ticket
      @ticket_start_action = TicketStartAction.find params[:ticket_start_action_id]
      if @ticket_start_action.present?
        @ticket_start_action.delete
      end
      respond_to do |format|
        format.html { redirect_to ticket_start_action_admins_tickets_path }
      end
    end

    def delete_admin_sla
      SlaTime
      @sla = SlaTime.find params[:sla_id]
      if @sla.present?
        @sla.delete
      end
      respond_to do |format|
        format.html { redirect_to ticket_sla_admins_tickets_path }
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
        render "admins/tickets/country"
      end

    end

    def reason
      Product
      if params[:edit]
        @mst_reason = Reason.find params[:mst_reason_id]
        if @mst_reason.update admin_reason_params
          params[:edit] = nil
          render json: @mst_reason
        end
      else
        if params[:create]
          @reason = Reason.new admin_reason_params
          if @reason.save
            params[:create] = nil
            @reason = Reason.new
          end
        else
          @reason = Reason.new
        end
        @reason_all = Reason.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/tickets/reason"
      end

    end

    def accessories
      Product
      Ticket
      if params[:edit]
        @admin_accessory = Accessory.find params[:accessory_id]
        if @admin_accessory.update admin_accessory_params
          params[:edit] = nil
          render json: @admin_accessory
        end
      else
        if params[:create]
          @accessory = Accessory.new admin_accessory_params
          if @accessory.save
            params[:create] = nil
            @accessory = Accessory.new
          end
        else
          @accessory = Accessory.new
        end
        @accessory_all = Accessory.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/tickets/accessories"
      end

    end

    def additional_charge
      TicketEstimation
      if params[:edit]
        @add_charge = AdditionalCharge.find params[:add_charge_id]
        if @add_charge.update admin_add_charge_params
          params[:edit] = nil
          render json: @add_charge
        end
      else
        if params[:create]
          @additional_charge = AdditionalCharge.new admin_add_charge_params
          if @additional_charge.save
            params[:create] = nil
            @additional_charge = AdditionalCharge.new
          end
        else
          @additional_charge = AdditionalCharge.new
        end
        @additional_charge_all = AdditionalCharge.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/tickets/additional_charge"
      end

    end


    def spare_part_description
      TicketSparePart
      TaskAction
      User
      Organization
      if params[:edit]
        @sp_description = SparePartDescription.find params[:sp_description_id]
        if  @sp_description.update sp_description_params
          params[:edit] = nil
          render json: @sp_description
        end
      else
        if params[:create]
          @spare_part_description = SparePartDescription.new sp_description_params
          if @spare_part_description.save
            params[:create] = nil
            @spare_part_description = SparePartDescription.new
          end
        else
          @spare_part_description = SparePartDescription.new
        end
        @spare_part_description_all = SparePartDescription.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/tickets/spare_part_description"
      end
    end

    def start_action
      Ticket
      if params[:edit]
        @ticket_start_action = TicketStartAction.find params[:ticket_start_action_id]
        if @ticket_start_action.update ticket_start_action_params
          params[:edit] = nil
          render json: @ticket_start_action
        end
      else
        if params[:create]
          @ticket_start_action = TicketStartAction.new ticket_start_action_params
          if @ticket_start_action.save
            params[:create] = nil
            @ticket_start_action = TicketStartAction.new
          end
        else
          @ticket_start_action = TicketStartAction.new
        end
        @ticket_start_action_all = TicketStartAction.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/tickets/start_action"
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
        render "admins/tickets/sla"
      end
    end


    private
      def admin_reason_params
        params.require(:reason).permit(:hold, :sla_pause, :re_assign_request, :terminate_job, :terminate_spare_part, :warranty_extend, :spare_part_unused, :reject_returned_part, :reject_close, :adjust_terminate_job_payment, :reason)
      end

      def admin_country_params
        params.require(:product_sold_country).permit(:Country, :code)
      end

      def admin_accessory_params
        params.require(:accessory).permit(:accessory)
      end

      def admin_add_charge_params
        params.require(:additional_charge).permit(:additional_charge, :default_cost_price, :default_estimated_price)
      end

      def sp_description_params
        params.require(:spare_part_description).permit(:description)
      end

      def ticket_start_action_params
        params.require(:ticket_start_action).permit(:action, :active)
      end

      def sla_params
        params.require(:sla_time).permit(:sla_time, :description, :created_by)
      end
  end
end