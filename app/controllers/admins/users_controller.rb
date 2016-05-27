module Admins
  class UsersController < ApplicationController
    layout "admins"

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

    private

      def title_params
        params.require(:mst_title).permit(:title)
      end
  end
end