module TodosHelper
  def send_request_process_data *args
    args = args.extract_options!
    response_hash = send_request args

    if response_hash["exception"].present?
      response = {status: "error"}
    else
      case 
      when args[:process_history]
        response = {status: "success", value: response_hash["value"], variable_id: response_hash["variable_id"]}

      when args[:start_process]
        response = {status: response_hash["process_instance"]["status"], process_name: response_hash["process_instance"]["process_id"], process_id: response_hash["process_instance"]["id"]}

      when args[:start_task]
        response = {status: response_hash["status"]}

      when args[:complete_task]
        response = {status: response_hash["status"]}

      when args[:task_list]
        response = {status: "success", content: response_hash["task_summary_list"]}

      end
    end
  end


  # private

    def deployment_id
      "lk.inova:INOCRM:0.0.5"
    end

    def base_url
      "http://192.168.1.202:8080/jbpm-console/rest"
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
        request.query = options[:query]
        response = HTTPI.post request

      when options[:process_history]
        request.url = "#{base_url}/#{process_history_path(options[:process_instance_id], options[:variable_id])}"
        request.query = options[:query]
        response = HTTPI.get request

      when options[:task_list]
        request.url = "#{base_url}/#{task_list_path}"
        # if owner is not empty? potential_owner = krisv
        # if process_instance_id is not empty? process_instance_id = 1
        request.query = {status: options[:status], processInstenceId: options[:process_instence_id]}.merge(options[:query])
        response = HTTPI.get request
      end
      Hash.from_xml response.body
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

    # def task_list_path(process_instance_id, owner_id, status)
    #   s = ""
    #   # if status
    #   #   s = "#{s}&status=#{status}"
    #   # end
    #   if owner_id
    #     s = "&potentialOwner=#{owner_id}"
    #   end
    #   if process_instance_id
    #     s = "#{s}&processInstenceId=#{process_instance_id}"
    #   end

    #   # status, (owner or process_id)
    #   "task/query?status=#{status}#{s}"
    # end
end
