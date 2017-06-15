module Admins
  class RolesController < ApplicationController
    layout "admins"

    def permissions
      Rpermission
    end

    def subject_attributes_form
      if params[:permission_id].present?
        @permission = Rpermission.find params[:permission_id]

        if params["save"].present?
          if @permission.update permission_params
            redirect_to permissions_admins_roles_url, notice: "Successfully saved"
          else
            flash[:notice] = "Unsuccessful"
            redirect_to permissions_admins_roles_url
          end
        end
      end
    end

    def filter_permissions
      if params[:type] == "filter_class"
        role = Role.find params[:value_key]
        @result = role.rpermissions.map{|r| [r.subject_class.name, r.subject_class.id]}.uniq
        @response = {option_html: view_context.options_for_select(@result)}

      elsif params[:type] == "filter_action"
        subject_class = SubjectClass.find params[:value_key]
        @result = subject_class.rpermissions.map{|s| [s.name, s.id]}
        @response = {option_html: view_context.options_for_select(@result)}

      end

      render json: @response

    end

    def permission_params
      params.require(:rpermission).permit(subject_attributes_attributes: [:name, :value, :_destroy])
    end

  end
end