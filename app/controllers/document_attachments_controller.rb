class DocumentAttachmentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_document_attachment, only: [:update, :destroy]
  respond_to :html, :xml, :json

  def create
    @document_attachment = DocumentAttachment.new(document_attachment_params)
    respond_to do |format|
      if @document_attachment.save
        format.json
      else
        flash[:error] = "Something gone error with document & attachment field. #{@document_attachment.errors.full_messages.join(',')}"
        # format.html {redirect_to edit_organization_url(@document_attachment.organization)}
        format.json {render json: @document_attachment.errors}
      end
    end
  end

  def update
    @document_attachment.update(document_attachment_params)
    # respond_with(@document_attachment)
    respond_to do |format|
      format.html {redirect_to edit_polymorphic_url([@document_attachment.attachable]), notice: "successfully updated."}
    end
  end

  def destroy
    @document_attachment.destroy
    # respond_with(@document_attachment)
    respond_to do |format|
      format.html {redirect_to edit_polymorphic_url([@document_attachment.attachable]), notice: "document is successfully deleted."}
    end
  end

  private
    def set_document_attachment
      @document_attachment = DocumentAttachment.find(params[:id])
    end

    def document_attachment_params
      params.require(:document_attachment).permit(:name, :file_path, :downloadable, :attachable_id, :attachable_type)
    end


end
