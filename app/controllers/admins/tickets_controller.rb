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
        format.html { redirect_to reason_admins_tickets_path }
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
        format.html { redirect_to accessories_admins_tickets_path}
      end
    end

    def delete_admin_additional_charge
      TicketEstimation
      @add_charge = AdditionalCharge.find params[:add_charge_id]
      if @add_charge.present?
        @add_charge.delete
      end
      respond_to do |format|
        format.html { redirect_to additional_charge_admins_tickets_path }
      end
    end

    def delete_admin_spare_part_description
      TicketSparePart
      @sp_description = SparePartDescription.find params[:sp_description_id]
      if @sp_description.present?
        @sp_description.delete
      end
      respond_to do |format|
        format.html { redirect_to spare_part_description_admins_tickets_path }
      end
    end

    def delete_admin_ticket_start_action
      Ticket
      @ticket_start_action = TicketStartAction.find params[:ticket_start_action_id]
      if @ticket_start_action.present?
        @ticket_start_action.delete
      end
      respond_to do |format|
        format.html { redirect_to start_action_admins_tickets_path }
      end
    end

    def delete_admin_sla
      SlaTime
      @sla = SlaTime.find params[:sla_id]
      if @sla.present?
        @sla.delete
      end
      respond_to do |format|
        format.html { redirect_to sla_admins_tickets_path }
      end
    end

    def reason
      Product
      if params[:edit]
        @mst_reason = Reason.find params[:mst_reason_id]
        if @mst_reason.attributes = reason_params
          if [:hold, :sla_pause, :re_assign_request, :terminate_job, :terminate_spare_part, :warranty_extend, :spare_part_unused, :reject_returned_part, :reject_close, :adjust_terminate_job_payment].any?{|c| @mst_reason.send(c) }
            params[:edit] = nil
            render json: @mst_reason
          else
            render json: "failed"
          end
        end
      else
        if params[:create]
          @reason = Reason.new reason_params
          if [:hold, :sla_pause, :re_assign_request, :terminate_job, :terminate_spare_part, :warranty_extend, :spare_part_unused, :reject_returned_part, :reject_close, :adjust_terminate_job_payment].any?{|c| @reason.send(c) }

            if @reason.save
              params[:create] = nil
              @reason = Reason.new
            end
            flash[:notice] = "Successfully saved!."
          else
            flash[:error] = "Please select ateast on condition"
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
        if @admin_accessory.update accessory_params
          params[:edit] = nil
          render json: @admin_accessory
        end
      else
        if params[:create]
          @accessory = Accessory.new accessory_params
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
        if @add_charge.update additional_charge_params
          params[:edit] = nil
          render json: @add_charge
        end
      else
        if params[:create]
          @additional_charge = AdditionalCharge.new additional_charge_params
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
        if  @sp_description.update spare_part_description_params
          params[:edit] = nil
          render json: @sp_description
        end
      else
        if params[:create]
          @spare_part_description = SparePartDescription.new spare_part_description_params
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

    def customer_feedback
      User

      if params[:edit]
        @ad_feedback = Feedback.find params[:customer_feedback_id]
        if @ad_feedback.update feedback_params
          params[:edit] = nil
          render json: @ad_feedback
        end
      else
        if params[:create]
          @customer_feedback = Feedback.new feedback_params
          if @customer_feedback.save
            params[:create] = nil
            @customer_feedback = Feedback.new
          end
        else
          @customer_feedback = Feedback.new
        end
        @customer_feedback_all = Feedback.order(created_at: :desc).select{|i| i.persisted? }
      end

    end

    def delete_admin_customer_feedback
      @ad_feedback = Feedback.find params[:customer_feedback_id]
      @ad_feedback.destroy
      flash[:notice] = "Successfully deleted!."
      redirect_to general_question_admins_tickets_url
    end

    def general_question
      QAndA

      if params[:edit]
        @g_question = GeQAndA.find params[:g_question_id]
        if @g_question.update ge_q_and_a_params
          params[:edit] = nil
          render json: @g_question
        end
      else
        if params[:create]
          @general_question = GeQAndA.new ge_q_and_a_params
          if @general_question.save
            params[:create] = nil
            @general_question = GeQAndA.new
          end
        else
          @general_question = GeQAndA.new
        end
        @general_question_all = GeQAndA.order(created_at: :desc).select{|i| i.persisted? }
      end

    end

    def delete_admin_general_question
      @g_question = GeQAndA.find params[:g_question_id]
      @g_question.destroy
      flash[:notice] = "Successfully deleted!."
      redirect_to general_question_admins_tickets_url
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
        elsif params[:edit_more]
          @problem_category = ProblemCategory.find params[:problem_category_id]

        elsif params[:update]
          @problem_category = ProblemCategory.find params[:problem_category_id]
          if @problem_category.update problem_category_params
            params[:update] = nil
            @problem_category = ProblemCategory.new
          end

        else
          @problem_category = ProblemCategory.new
        end

        @problem_category_all = ProblemCategory.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def delete_problem_category
      @problem_category = ProblemCategory.find params[:problem_category_id]
      if @problem_category.present?
        @problem_category.delete
      end
      respond_to do |format|
        format.html { redirect_to problem_and_category_admins_tickets_path }
      end
    end

    def delete_q_and_a
      @q_and_a = QAndA.find params[:q_and_a_id]
      if @q_and_a.present?
        @q_and_a.delete
      end
      respond_to do |format|
        format.html { redirect_to problem_and_category_admins_tickets_path }
      end
    end

    private
      def reason_params
        params.require(:reason).permit(:hold, :sla_pause, :re_assign_request, :terminate_job, :terminate_spare_part, :warranty_extend, :spare_part_unused, :reject_returned_part, :reject_close, :adjust_terminate_job_payment, :reason)
      end

      def accessory_params
        params.require(:accessory).permit(:accessory)
      end

      def additional_charge_params
        params.require(:additional_charge).permit(:additional_charge, :default_cost_price, :default_estimated_price)
      end

      def spare_part_description_params
        params.require(:spare_part_description).permit(:description)
      end

      def ticket_start_action_params
        params.require(:ticket_start_action).permit(:action, :active)
      end
      def feedback_params
        params.require(:feedback).permit(:feedback)
      end

      def ge_q_and_a_params
        params.require(:ge_q_and_a).permit(:question, :answer_type, :active, :compulsory, :action_id)
      end

      def problem_category_params
        params.require(:problem_category).permit(:name ,q_and_as_attributes: [:_destroy, :id, :question, :answer_type, :active, :action_id, :compulsory])
      end

      def problem_category2_params
        params.require(:problem_category).permit(:name,q_and_as_attributes: [:question, :answer_type, :active, :action_id, :compulsory])
      end

      def q_and_a_params
        params.require(:q_and_a).permit(:question, :answer_type, :active, :action_id, :compulsory)
      end
  end
end