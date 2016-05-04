class TodosController < ApplicationController
  def index

    @potential_owner = current_user.roles.find_by_id(current_user.current_user_role_id).bpm_module_roles.first.try :code
    @todo_list_for_role = []
    @workflow_mapping_for_role = []

    @todo_list_for_user = []
    @workflow_mapping_for_user = []

    if @potential_owner
      ["InProgress", "Reserved", "Ready"].each do |status|
        @todo_list_for_role << view_context.send_request_process_data(task_list: true, status: status, potential_owner: @potential_owner, query: {})
      end

      @task_content_for_role = @todo_list_for_role.map { |list| list[:content] and list[:content]["task_summary"] }.compact.flatten

      @task_content_for_role.each do |task_content|
        @workflow_mapping_for_role << {workflow_mapping: Rails.cache.fetch([:workflow_mapping_role, task_content["name"]]){WorkflowMapping.where(task_name: task_content["name"], process_name: task_content["process_id"]).first}, workflow_header: Rails.cache.fetch([:workflow_header, task_content["process_instance_id"]]){WorkflowHeaderTitle.find_by_process_id(task_content["process_instance_id"])}, task_content: task_content}
      end
      @formatted_workflow_mapping_for_role = @workflow_mapping_for_role.map{|w| {process_name: w[:workflow_mapping].process_name, task_name: w[:workflow_mapping].task_name, url: w[:workflow_mapping].url, first_header_title: w[:workflow_mapping].first_header_title, second_header_title_name: w[:workflow_mapping].second_header_title_name, input_variables: w[:workflow_mapping].input_variables, second_header_title: (w[:workflow_header].send(w[:workflow_mapping].second_header_title_name.to_sym) if w[:workflow_header] and w[:workflow_mapping].second_header_title_name.present?), task_content: w[:task_content]}}

    end

    ["InProgress", "Reserved", "Ready"].each do |status|
      @todo_list_for_user << view_context.send_request_process_data(task_list: true, status: status, potential_owner: current_user.id, query: {})
    end

    @task_content_for_user = @todo_list_for_user.map { |list| list[:content] and list[:content]["task_summary"] }.compact.flatten

    @task_content_for_user.each do |task_content|
      @workflow_mapping_for_user << {workflow_mapping: Rails.cache.fetch([:workflow_mapping_user, task_content["name"]]){WorkflowMapping.where(task_name: task_content["name"], process_name: task_content["process_id"]).first}, workflow_header: Rails.cache.fetch([:workflow_header, task_content["process_instance_id"]]){WorkflowHeaderTitle.find_by_process_id(task_content["process_instance_id"])}, task_content: task_content}
    end

    @formatted_workflow_mapping_for_user = @workflow_mapping_for_user.map{|w| {process_name: w[:workflow_mapping].process_name, task_name: w[:workflow_mapping].task_name, url: w[:workflow_mapping].url, first_header_title: w[:workflow_mapping].first_header_title, second_header_title_name: w[:workflow_mapping].second_header_title_name, input_variables: w[:workflow_mapping].input_variables, second_header_title: (w[:workflow_header].send(w[:workflow_mapping].second_header_title_name.to_sym) if w[:workflow_header].present? and w[:workflow_mapping].second_header_title_name.present?), task_content: w[:task_content]}}

    Rails.cache.fetch([:formatted_workflow_mapping_for_user]) { @formatted_workflow_mapping_for_user }
    # @formatted_workflow_mapping_for_user = @formatted_workflow_mapping_for_user_without_pagi.page(params[:page]).per(20)

  end

  def work_flow_mapping_sort
    
  end

  def to_do_call
    url = params[:url]
    process_instance_id = params[:process_instance_id]
    input_variables = params[:input_variables]
    task_id = params[:task_id]
    owner = params[:owner]

    @bpm_response_start_task = view_context.send_request_process_data start_task: true, task_id: task_id

    # To avoid call completed task again, check the status
    @bpm_response_exist = view_context.send_request_process_data task_list: true, status: "InProgress", query: {taskId: task_id}

    if @bpm_response_exist[:content].present?
      @bpm_input_variables = []
      input_variables.split(",").each do |input_variable|
        @bpm_input_variables << view_context.send_request_process_data(process_history: true, process_instance_id: process_instance_id, variable_id: input_variable)
      end
      session[:process_id] = process_instance_id
      session[:task_id] = task_id
      session[:owner] = owner
      # session[:bpm_input_variables] = @bpm_input_variables.map{|e| [e[:variable_id], e[:value]]}
      session[:engineer_id] = @bpm_input_variables.map{|e| [e[:variable_id], e[:value]]}.detect{ |v| v.first == "engineer_id"}.try(:last)

      session[:cache_key] = [url, task_id]
      Rails.cache.fetch(session[:cache_key]){ {process_id: process_instance_id, task_id: task_id, owner: owner, bpm_input_variables: @bpm_input_variables.map{|e| [e[:variable_id], e[:value]]} } }

      @redirect_url = "#{url}?process_id=#{process_instance_id}&task_id=#{task_id}&owner=#{owner}&#{@bpm_input_variables.map{|e| e[:variable_id]+'='+e[:value]}.join('&')}"
    else
      Rails.cache.delete(session[:cache_key])
      @redirect_url = todos_url
      @flash_message = "Task is not available."
    end
    redirect_to @redirect_url, notice: @flash_message
  end
end