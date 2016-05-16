module Admins
  class EmployeesController < ApplicationController
    layout "admins"

    def index
    end

    def delete_admin_sbu_engineer
      User
      @sbu_eng = User.find params[:user_id]
      if @sbu_eng.present?
        @sbu_eng.delete
      end
      respond_to do |format|
        format.html { redirect_to employee_sbu_admins_employees_path }
      end
    end

    def delete_admin_sbu
      User
      @sbu = Sbu.find params[:sbu_id]
      if @sbu.present?
        @sbu.delete
      end
      respond_to do |format|
        format.html { redirect_to employee_sbu_admins_employees_path }
      end
    end

    # # PUT params[:sbu_id]
    # def sbu_engineer
    # # def sbu
    #   if params[:edit]
    #     if params[:use_id]
    #       @sbu_engineer = User.find params[:use_id]
    #       @sbu_engineer.update sbu_engineer_params
    #       render @sbu_engineer
    #     elsif params[:sbu_id]
    #       @sbu = Sbu.find params[:sbu_id]
    #       @sbu.update sbu_params
    #       render @sbu
    #     end
    #   else
    #     @sbu = Sbu.new sbu_params
    #     if @sbu.save
    #       flash[:notice] = "Successfully saved"
    #     else
    #       flash[:error] = "Unable to save"
    #     end
    #     redirect_to _url
    #   end

    #   # link_to "", path(edit: true, sbu_engineer_id: 1)
    #   # link_to "", path(edit: true, sbu_id: 1)

    # end

    def sbu
      User

      if params[:edit]
        if params[:engineer_id]
          @sbu_eng = SbuEngineer.find params[:engineer_id]
          if @sbu_eng.update sbu_eng_params
            params[:edit] = nil
            render json: @sbu_eng
          end
        elsif params[:sbu_id]
          @sbu = Sbu.find params[:sbu_id]
          if @sbu.update sbu_params
            params[:edit] = nil
            render json: @sbu
          end
        end
      else
        if params[:create]
          @sbu = Sbu.new sbu_params
          if @sbu.save
            params[:create] = nil
            @sbu = Sbu.new
          end
        else
          @sbu = Sbu.new
        end
        @sbu_all = Sbu.order(created_at: :desc).select{|i| i.persisted? }
        render "admins/employees/sbu"
      end
    end

    private
      def sbu_params
        params.require(:sbu).permit(:sbu, sbu_engineers_attributes: [:_destroy, :id, :engineer_id])
      end

      def sbu_eng_params
        params.require(:sbu_engineer).permit(:engineer_id)
      end
  end
end