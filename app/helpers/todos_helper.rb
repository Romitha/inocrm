module TodosHelper
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
      request.url = "#{base_url}/#{start_process_path(options[:deployment_id], options[:process_id])}"
      request.query = options[:query]
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
      request.query = options[:query]
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
end
