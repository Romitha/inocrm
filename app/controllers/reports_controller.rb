class ReportsController < ApplicationController
  layout "report_pdf"

	def quotation
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name"
      end
    end
  end

  def excel_output
    respond_to do |format|
      format.html
      format.xls
    end
  end
end
