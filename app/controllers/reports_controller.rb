class ReportsController < ApplicationController
  layout "report_pdf"

  def show
    # https://github.com/mileszs/wicked_pdf
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
