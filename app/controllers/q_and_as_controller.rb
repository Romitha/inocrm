class QAndAsController < ApplicationController

  def q_and_answer_record
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @problem_category = @ticket.problem_category
  end

  private
    def problem_category_params
      params.require(:ticket).permit(q_and_answers_attributes: [:problematic_question_id, :answer, :id])
    end
end
