class QAndAsController < ApplicationController
  before_action :authenticate_user!

	def q_and_answer_record
		@ticket = Ticket.find(session[:ticket_id])
		@problem_category = @ticket.problem_category
	end

	def q_and_answer_save
		@ticket = Ticket.find(session[:ticket_id])
		@warranty = Warranty.find(session[:warranty_id]) if session[:warranty_id]
		@problem_category = ProblemCategory.find params[:problem_category_id]

		if @problem_category.update(problem_category_params)
			render "tickets/remarks"
		else
			render :q_and_answer_record
		end
	end

	private
		def problem_category_params
			params.require(:problem_category).permit(q_and_as_attributes: [:id, q_and_answers_attributes: [:id, :ticket_id, :problematic_question_id, :answer]])
		end
end
