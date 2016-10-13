module TodosHelper
  HTTPI.adapter = :net_http

  def send_request_process_data *args
    args = args.extract_options!
    response_hash = send_request args

    if response_hash["exception"].present?
      response = {status: "error"}
    else
      case 
      when args[:process_history]

        if response_hash["log_instance_list"].blank?
          response = {status: "success"}
        elsif response_hash["log_instance_list"]["variable_instance_log"].is_a?(Hash)
          response = {status: "success", value: response_hash["log_instance_list"]["variable_instance_log"]["value"], variable_id: response_hash["log_instance_list"]["variable_instance_log"]["variable_id"]}
        elsif response_hash["log_instance_list"]["variable_instance_log"].is_a?(Array)
          response = {status: "success", value: response_hash["log_instance_list"]["variable_instance_log"].last["value"], variable_id: response_hash["log_instance_list"]["variable_instance_log"].last["variable_id"]}
        end

      when args[:start_process]
        response = response_hash[versionized_bpm_wrapper[:start_process]].blank? ? {} : {status: response_hash[versionized_bpm_wrapper[:start_process]]["status"], process_name: response_hash[versionized_bpm_wrapper[:start_process]]["process_id"], process_id: response_hash[versionized_bpm_wrapper[:start_process]]["id"]}

      when args[:start_task]
        response = response_hash["response"] ? {status: response_hash["response"]["status"]} : {}

      when args[:complete_task]
        response = response_hash["response"] ? {status: response_hash["response"]["status"]} : {}

      when args[:task_list]
        response = {status: "success", content: response_hash[versionized_bpm_wrapper[:task_list]]}
      end
    end
  end

  private

    def deployment_id
      # "lk.inova:INOCRM:0.0.3"
      # "lk.inova:INOCRM:0.0.7"
      # "lk.inova:INOCRM:0.0.8"
      # "lk.inova:INOCRM:0.0.9"
      # "lk.inova:INOCRM:0.0.0.1"
      # "lk.inova:INOCRM:0.0.0.3"
      case Rails.env
      when "development"
        # "lk.inova:INOCRM:0.0.0.4"
        # "lk.inova:INOCRM:1.0.0.5"
        # "lk.inova:INOCRM:1.0.0.6"
        # "lk.inova:INOCRM:1.0.0.9"
        "lk.inova:INOCRM:1.0.1.0"
      when "production"
        # "lk.inova:INOCRM:1.0.0.4"
        # cloned from github
        # "lk.inova:INOCRM:1.0.0.5"
        # "lk.inova:INOCRM:1.0.0.6"
        # "lk.inova:INOCRM:1.0.0.9"
        "lk.inova:INOCRM:1.0.1.0"
      when "test"
        "lk.inova:INOCRM:1.0.1.0"
      when "staging"
        "lk.inova:INOCRM:1.0.1.0"
      end
        
    end

    def versionized_bpm_wrapper
      case Rails.env
      when "development"
        {start_process: "process_instance", task_list: "task_summary_list"}
      when "production"
        {start_process: "process_instance", task_list: "task_summary_list"}
      when "staging"
        {start_process: "process_instance_response", task_list: "task_summary_list_response"}
      else
        {}
      end
    end

    def base_url
      if Rails.env == "staging"
        "http://192.168.50.157:8080/jbpm-console/rest"
      elsif Rails.env == "production"
        "http://192.168.1.232:8080/jbpm-console/rest"
      else
        "http://192.168.50.157:8080/jbpm-console/rest"
        # "http://192.168.1.232:8080/jbpm-console/rest"
      end
      # curl -X POST -H "Accept:application/xml" -H "Content-type:application/json" -H "Authorization: Basic a3Jpc3Y6a3Jpc3Y=" http://192.168.1.202:8080/jbpm-console/rest/runtime/org.Test1234:test1234:3.3/process/test1234.test1a/start\?map_name\=wanni\&map_age\=27\&map_user\=anu
    end

    def send_request *args
      options = args.extract_options!
      request = initiate_request
      response = nil
      case
      when options[:start_process]
        request.url = "#{base_url}/#{start_process_path(deployment_id, options[:process_name])}"
        request.query = options[:query].inject({}){|init, (key, value)| init.merge("map_#{key}"=> value)}
        response = HTTPI.post request

      when options[:start_task]
        request.url = "#{base_url}/#{start_task_path(options[:task_id])}"
        request.query = options[:query]
        response = HTTPI.post request

      when options[:complete_task]
        request.url = "#{base_url}/#{complete_task_path(options[:task_id])}"
        request.query = options[:query].inject({}){|init, (key, value)| init.merge("map_#{key}"=> value)}
        response = HTTPI.post request

      when options[:process_history]
        request.url = "#{base_url}/#{process_history_path(options[:process_instance_id], options[:variable_id])}"
        request.query = options[:query]
        response = HTTPI.get request

      when options[:task_list]
        request.url = "#{base_url}/#{task_list_path}"

        compulsory_query = {status: options[:status]}
        
        compulsory_query.merge!(processInstanceId: options[:process_instance_id]) if options[:process_instance_id]
        compulsory_query.merge!(potentialOwner: options[:potential_owner]) if options[:potential_owner]
        compulsory_query.merge!(options[:query]) if options[:query]

        request.query = compulsory_query
        response = HTTPI.get request
      end
      Hash.from_xml response.body
      # sleep 5
      # request.url
    end

    def initiate_request
      request = HTTPI::Request.new
      request.headers = {"Authorization" => "Basic a3Jpc3Y6a3Jpc3Y=", "Content-type" => "application/json", "Accept" => "application/xml"}
      request
    end

    def start_process_path(deployment_id, process_id)
      "runtime/#{deployment_id}/process/#{process_id}/start"
    end

    def start_task_path(task_id)
      "task/#{task_id}/start"
    end

    def complete_task_path(task_id)
      "task/#{task_id}/complete"
    end

    def process_history_path(process_instance_id, variable_id)
      "history/instance/#{process_instance_id}/variable/#{variable_id}"
    end

    def task_list_path
      "task/query"
    end

  def initialize_bpm_variables
    {
      d1_pop_approval_pending: "N",
      d2_recorrection: "N",
      d3_regional_support_job: "N",
      d4_job_complete: "N",
      d5_re_assigned: "N",
      d6_close_approval_required: "N",
      d7_close_approval_requested: "N",
      d8_job_finished: "N",
      d9_qc_required: "N",
      d10_job_estimate_required_final: "N",
      d11_terminate_job: "N",
      d12_need_to_invoice: "N",
      d13_job_estimate_requested_external: "N",
      d14_job_estimate_external_below_margin: "N",
      d15_part_estimate_required: "N",
      d16_request_manufacture_part: "N",
      d17_request_store_part: "N", 
      d18_approve_request_store_part: "N", 
      d19_estimate_internal_below_margin: "N", 
      d20_advance_payment_required: "N",
      d21_edit_serial_no: "N",
      d22_deliver_unit: "N", 
      d23_delivery_items_pending: "N", 
      d24_return_store_part: "N",
      d25_terminate_order_part: "N",
      d26_serial_no_change_warranty_extend_requested: "N",
      d27_warranty_extend_requested: "N",
      d28_request_store_part_2: "N",
      d29_part_estimate_required_2: "N",
      d30_parts_collection_pending: "N",
      d31_more_parts_collection_pending: "N",
      d32_return_manufacture_part: "N",
      d33_return_part_reject: "N",
      d34_event_closed: "N",
      d35_parts_bundle_pending: "N",
      d36_more_parts_bundle_pending: "N",
      d37_qc_passed: "N",
      d38_ticket_close_approved: "N",
      d39_re_open: "N",
      d40_ticket_approved_to_close: "N",
      d41_re_open: "N",
      part_estimation_id: "-",
      request_spare_part_id: "-",
      request_onloan_spare_part_id: "-",
      onloan_request: "N",
      advance_payment_estimation_id: "-",
      deliver_unit_id: "-",
      supp_engr_user: "-",
      engineer_id: "-",
    }
  end

  def bpm_check task_id, process_id, owner
    # ticket_id, process_id, task_id should not be null
    # http://0.0.0.0:3000/tickets/assign-ticket?ticket_id=2&process_id=212&owner=supp_mgr&task_id=191
    if task_id and process_id and owner

      availability_of_task = []

      bpm_response = send_request_process_data process_history: true, process_instance_id: process_id, variable_id: "ticket_id"

      if bpm_response[:status].upcase != "ERROR"

        availability_of_task << send_request_process_data(task_list: true, status: "InProgress", process_instance_id: process_id)
        availability_of_task << send_request_process_data(task_list: true, status: "Reserved", process_instance_id: process_id)

        availability_of_task_content = availability_of_task.any? { |e| e[:content].present? and (e[:content]["task_summary"].is_a?(Array) ? e[:content]["task_summary"].map{|id| id["id"]}.include?(task_id.to_s) : e[:content]["task_summary"]["id"] == task_id.to_s) }
      else
        false
      end

    else
      false
    end    
  end

end


# bpm affecting methods
# finalize_ticket_save