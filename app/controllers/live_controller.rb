# class LiveController < WebsocketRails::BaseController
#   def create
#     # The `message` method contains the data received
#     task = Task.new message
#     if task.save
#       send_message :create_success, task, :namespace => :tasks
#     else
#       send_message :create_fail, task, :namespace => :tasks
#     end
#   end
# end