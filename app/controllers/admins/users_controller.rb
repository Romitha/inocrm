module Admins
  class UsersController < ApplicationController

    def delete_admin_customer_feedback
      User
      @customer_feedback = Feedback.find params[:customer_feedback_id]
      if @customer_feedback.present?
        @customer_feedback.delete
      end
      respond_to do |format|
        format.html { redirect_to user_customer_feedback_admins_users_path }
      end

    end

    def delete_admin_general_question
      QAndA
      @g_question = GeQAndA.find params[:g_question_id]
      if @g_question.present?
        @g_question.delete
      end
      respond_to do |format|
        format.html { redirect_to user_general_question_admins_users_path }
      end
    end

    def delete_admin_title
      User
      @title = MstTitle.find params[:title_id]
      if @title.present?
        @title.delete
      end
      respond_to do |format|
        format.html { redirect_to user_title_admins_users_path }
      end
    end

    def customer_feedback
      User

      if params[:edit]
        @ad_feedback = Feedback.find params[:customer_feedback_id]
        if @ad_feedback.update admin_customer_feedback_params
          params[:edit] = nil
          render json: @ad_feedback
        end
      else
        if params[:create]
          @customer_feedback = Feedback.new admin_customer_feedback_params
          if @customer_feedback.save
            params[:create] = nil
            @customer_feedback = Feedback.new
          end
        else
          @customer_feedback = Feedback.new
        end
        @customer_feedback_all = Feedback.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/users/customer_feedback"
      end

    end

    def general_question
      QAndA

      if params[:edit]
        @g_question = GeQAndA.find params[:g_question_id]
        if @g_question.update admin_general_question_params
          params[:edit] = nil
          render json: @g_question
        end
      else
        if params[:create]
          @general_question = GeQAndA.new admin_general_question_params
          if @general_question.save
            params[:create] = nil
            @general_question = GeQAndA.new
          end
        else
          @general_question = GeQAndA.new
        end
        @general_question_all = GeQAndA.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/users/general_question"
      end

    end

    def title
      User

      if params[:edit]
        @title = MstTitle.find params[:title_id]
        if @title.update title_params
          params[:edit] = nil
          render json: @title
        end
      else
        if params[:create]
          @title = MstTitle.new title_params
          if @title.save
            params[:create] = nil
            @title = MstTitle.new
          end
        else
          @title = MstTitle.new
        end
        @title_all = MstTitle.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/users/title"
      end

    end

    private
      def admin_customer_feedback_params
        params.require(:feedback).permit(:feedback)
      end

      def admin_general_question_params
        params.require(:ge_q_and_a).permit(:question, :answer_type, :active, :compulsory, :action_id)
      end

      def title_params
        params.require(:mst_title).permit(:title)
      end
  end
end