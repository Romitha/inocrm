module Admins
  class EmployeesController < ApplicationController
    layout "admins"

    def index
    end

    def delete_admin_sbu_engineer
      User
      @sbu = Sbu.find params[:sbu_id]
      @sbu_eng = User.find params[:user_id]
      @sbu.engineers.delete @sbu_eng
      respond_to do |format|
        format.html { redirect_to sbu_admins_employees_path }
      end
    end

    def delete_admin_sbu
      User
      @sbu = Sbu.find params[:sbu_id]
      if @sbu.present?
        @sbu.delete
      end
      respond_to do |format|
        format.html { redirect_to sbu_admins_employees_path }
      end
    end

    def sbu
      User

      if params[:edit]
        if params[:engineer_id]
          @sbu_eng = SbuEngineer.find params[:engineer_id]
          if @sbu_eng.update sbu_eng_params
            params[:edit] = nil
            render json: @sbu_eng
          else
            render json: @sbu_eng.errors.full_messages.join
          end
        elsif params[:sbu_id]
          @sbu = Sbu.find params[:sbu_id]
          if @sbu.update sbu_params
            params[:edit] = nil
            render json: @sbu
          else
            render json: @sbu.errors.full_messages.join
          end
        end
      else
        if params[:create]
          @sbu = Sbu.new sbu_params
          if @sbu.save
            params[:create] = nil
            @sbu = Sbu.new
          end

        elsif params[:edit_more]
          @sbu = Sbu.find params[:sbu_id]

        elsif params[:update]
          @sbu = Sbu.find params[:sbu_id]
          if @sbu.update sbu_params
            params[:update] = nil
            @sbu = Sbu.new
          end

        else
          @sbu = Sbu.new
        end
        @sbu_all = Sbu.order(created_at: :desc).select{|i| i.persisted? }
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