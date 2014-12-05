class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # check_authorization

  layout :layout_by_resource

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
end
