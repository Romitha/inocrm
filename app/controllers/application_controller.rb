class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  # check_authorization

  layout :layout_by_resource

  before_filter :user_session_expired

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  # def current_ability
  #   @current_ability ||= Ability.new(current_user)
  # end

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  protected
    def layout_by_resource
      if devise_controller?
        "devise_template"
      else
        "application"
      end
    end

    def user_session_expired
      if request.xhr?
        if verified_request?
          render js: "alert('session expired'); window.location.href='#{root_url}';" unless user_signed_in?
        else
          render js: "alert('session expired'); window.location.href='#{root_url}';" unless user_signed_in?
        end
      else
        authenticate_user!
      end
    end

    def update_headers(process_name, ticket)
      ticket.ticket_workflow_processes.where(process_name: process_name).each do |process|
        process_id = process.process_id

        view_context.ticket_bpm_headers process_id, ticket.id
        Rails.cache.delete([:workflow_header, process_id])

      end

    end

    def load_more_todo(process_id, *args)
      Ticket
      args_hash = args.extract_options!
      # response_hash = []
      final_query_hash = {process_id: process_id, ticket_id: args_hash[:ticket_id], engineer_id: args_hash[:engineer_id], spare_part_id: args_hash[:request_spare_part_id], onloan_spare_part_id: args_hash[:request_onloan_spare_part_id], estimation_id: args_hash[:part_estimation_id]}.reject{|k, v| !v.present? }
      # @processes = TicketWorkflowProcess.where(final_query_hash)
      process = TicketWorkflowProcess.where(final_query_hash).last

      # @processes.each do |process|
      #   response = {}

      #   response[:ticket] = {header: "Ticket Info", ticket_no: process.ticket.support_ticket_no} if process.ticket.present?

      #   response[:ticket_engineer] = {header: "Engineer Info", full_name: process.ticket_engineer.full_name} if process.ticket_engineer.present?

      #   response[:ticket_spare_part] = {header: "Spare Part Info", spare_part_no: process.ticket_spare_part.spare_part_no, faulty_ct_no: process.ticket_spare_part.faulty_ct_no, faulty_serial_no: process.ticket_spare_part.faulty_serial_no, } if process.ticket_spare_part.present?

      #   response[:ticket_on_loan_spare_part] = {header: "On Loan Info", requested_at: process.ticket_on_loan_spare_part.spare_part_no, requested_by: process.ticket_on_loan_spare_part.requested_user } if process.ticket_on_loan_spare_part.present?

      #   response[:ticket_estimation] = {header: "Estimation Info", estimation_at: process.ticket_estimation.estimated_at.strftime("%d/ %m/%Y at %H:%M:%S"), estimated_by: process.ticket_estimation.estimated_by_user.try(:full_name) } if process.ticket_estimation.present?

      #   response_hash << response

      # end

      response = {}

      case process.class.to_s
      when "TicketWorkflowProcess"
        response[:main_info] = {header: "Main Information", ticket_no: process.ticket.support_ticket_no, product_info: {brand: process.ticket.products.last.brand_name, category: process.ticket.products.last.category_full_name("|"), model_number: process.ticket.products.last.model_no, product_number: process.ticket.products.last.product_no, serial_no: process.ticket.products.last.serial_no, name: process.ticket.products.last.name}, customer_info: {customer_name: process.ticket.customer.full_name, address: process.ticket.customer.full_address}, contact_person_info: {name: process.ticket.send("contact_person#{process.ticket.inform_cp}").full_name, contact_infos: process.ticket.send("contact_person#{process.ticket.inform_cp}").contact_person_contact_types.map(&:contact_info)}}
      end

      # response_hash << response

      # return response_hash
      return response
    end

end
