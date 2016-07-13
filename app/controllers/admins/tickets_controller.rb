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

    def delete_dispatch_method
      Invoice
      @dispatch_method = DispatchMethod.find params[:dispatch_method_id]
      if @dispatch_method.present?
        @dispatch_method.delete
      end
      respond_to do |format|
        format.html { redirect_to dispatch_method_admins_tickets_path}
      end
    end

    def delete_payment_term
      TaskAction
      @payment_term = PaymentTerm.find params[:payment_term_id]
      if @payment_term.present?
        @payment_term.delete
      end
      respond_to do |format|
        format.html { redirect_to payment_term_admins_tickets_path }
      end
    end

    def delete_admin_payment_item
      TaskAction
      @payment_item = PaymentItem.find params[:payment_item_id]
      if @payment_item.present?
        @payment_item.delete
      end
      respond_to do |format|
        format.html { redirect_to payment_item_admins_tickets_path }
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
            render json: @mst_reason.errors.full_messages.join
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
        @reason_all = Reason.order(updated_at: :desc)
        render "admins/tickets/reason"
      end

    end

    def payment_item
      TaskAction

      if params[:edit]
        @payment_item = PaymentItem.find params[:payment_item_id]
        if @payment_item.update admin_payment_item_params
          params[:edit] = nil
          render json: @payment_item
        else
          render json: @payment_item.errors.full_messages.join
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
        @payment_item_all = PaymentItem.order(updated_at: :desc)
      end
    end

    def payment_term
      Invoice
      if params[:edit]
        @payment_term = PaymentTerm.find params[:payment_term_id]
        if @payment_term.update payment_term_params
          params[:edit] = nil
          render json: @payment_term
        else
          render json: @payment_term.errors.full_messages.join
        end

      else
        if params[:create]
          @payment_term = PaymentTerm.new payment_term_params
          if @payment_term.save
            params[:create] = nil
            @payment_term = PaymentTerm.new
          end
        else
          @payment_term = PaymentTerm.new
        end
        @payment_term_all = PaymentTerm.order(updated_at: :desc)
      end
    end

    def dispatch_method
      Invoice
      if params[:edit]
        @dispatch_method = DispatchMethod.find params[:dispatch_method_id]
        if @dispatch_method.update dispatch_method_params
          params[:edit] = nil
          render json: @dispatch_method
        else
          render json: @dispatch_method.errors.full_messages.join
        end
      else
        if params[:create]
          @dispatch_method = DispatchMethod.new dispatch_method_params
          if @dispatch_method.save
            params[:create] = nil
            @dispatch_method = DispatchMethod.new
          end
        else
          @dispatch_method = DispatchMethod.new
        end
        @dispatch_method_all = DispatchMethod.order(updated_at: :desc)
        render "admins/tickets/dispatch_method"
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
        else
          render json: @admin_accessory.errors.full_messages.join
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
        @accessory_all = Accessory.order(updated_at: :desc)
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
        else
          render json: @add_charge.errors.full_messages.join
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
        @additional_charge_all = AdditionalCharge.order(updated_at: :desc)
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
        else
          render json: @sp_description.errors.full_messages.join
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
        @spare_part_description_all = SparePartDescription.order(updated_at: :desc)
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
        else
          render json: @ticket_start_action.errors.full_messages.join
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
        @ticket_start_action_all = TicketStartAction.order(updated_at: :desc)
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
        else
          render json: @ad_feedback.errors.full_messages.join
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
        @customer_feedback_all = Feedback.order(updated_at: :desc)
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
        else
          render json: @g_question.errors.full_messages.join
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
        @general_question_all = GeQAndA.order(updated_at: :desc)
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
          else
            render json: @problem_category.errors.full_messages.join
          end
        elsif params[:q_and_a_id]
          @q_and_a = QAndA.find params[:q_and_a_id]
          if @q_and_a.update q_and_a_params
            params[:edit] = nil
            render json: @q_and_a
          else
            render json: @q_and_a.errors.full_messages.join
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

        @problem_category_all = ProblemCategory.order(updated_at: :desc)
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
          else
            render json: @brands_and_category.errors.full_messages.join
          end
        elsif params[:product_category_id]
          @product_category = ProductCategory.find params[:product_category_id]
          if @product_category.update product_category_params
            params[:edit] = nil
            render json: @product_category
          else
            render json: @product_category.errors.full_messages.join
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

        elsif params[:edit_more]
          @brands_and_category = ProductBrand.find params[:brands_and_category_id]

        elsif params[:update]
          @brands_and_category = ProductBrand.find params[:brands_and_category_id]
          if @brands_and_category.update brands_and_category_params
            params[:update] = nil
            @brands_and_category = ProductBrand.new
          end


        else
          @brands_and_category = ProductBrand.new
        end
        @brands_and_category_all = ProductBrand.order(updated_at: :desc)
      end
    end

    def delete_admin_brands_and_category
      Product
      @brands_and_category = ProductBrand.find params[:brands_and_category_id]
      if @brands_and_category.present?
        @brands_and_category.delete
      end
      respond_to do |format|
        format.html { redirect_to brands_and_category_admins_inventories_path }
      end
    end

    private

      def admin_payment_item_params
        params.require(:payment_item).permit(:name, :default_amount)
      end

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

      def dispatch_method_params
        params.require(:dispatch_method).permit(:name)
      end

      def payment_term_params
        params.require(:payment_term).permit(:name, :description)
      end

      def brands_and_category_params
        params.require(:product_brand).permit(:organization_id, :currency_id, :sla_id, :name, :parts_return_days, :warranty_date_format, product_categories_attributes: [:_destroy, :id, :sla_id, :name])
      end

      def product_category_params
        params.require(:product_category).permit(:name, :sla_id)
      end
  end
end