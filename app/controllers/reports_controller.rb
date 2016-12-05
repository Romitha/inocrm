class ReportsController < ApplicationController
	layout "report_pdf"

	def show
    respond_to do |format|
    	format.html
      format.pdf do
        render pdf: "file_name"
      end
    end
  end
end
