class AttachmentsController < ApplicationController
  before_action :set_card,       only: %i[create]
  before_action :set_attachment, only: %i[destroy]

  def create
    @card.attachments.attach(params[:attachments]) if params[:attachments].present?
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    @attachment.purge
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("attachment_#{@attachment.id}") }
      format.html { redirect_to card_path(@card) }
    end
  end

  private

  def set_card
    @card = Card.accessible_to(current_user).find(params[:card_id])
  end

  def set_attachment
    @attachment = ActiveStorage::Attachment.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @attachment.record_type == "Card"
    @card = Card.accessible_to(current_user).find(@attachment.record_id)
  end
end
