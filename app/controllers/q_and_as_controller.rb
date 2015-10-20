class QAndAsController < ApplicationController

  def q_and_answer_record
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @problem_category = @ticket.problem_category
  end

  def update_ticket_q_and_a
    QAndA
    @ticket = Ticket.find params[:ticket_id]
    if @ticket.update problem_category_params

      WebsocketRails[:posts].trigger 'new', {task_name: "Q and A for the ticket", task_id: @ticket.id, task_verb: "updated.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

      redirect_to todos_url, notice: "Successfully updated."
    else
      redirect_to todos_url, alert: "Successfully updated."
    end
  end

  private
    def problem_category_params
      params.require(:ticket).permit(q_and_answers_attributes: [:problematic_question_id, :ticket_action_id, :answer, :id], ge_q_and_answers_attributes: [:general_question_id, :ticket_action_id, :answer, :id])
    end
end