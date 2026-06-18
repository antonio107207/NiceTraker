class CardLabelsController < ApplicationController
  before_action :set_card,       only: %i[create]
  before_action :set_card_label, only: %i[destroy]

  def create
    label = @card.board.labels.find(params[:label_id])
    @card.card_labels.find_or_create_by!(label: label)
    @card   = Card.includes(:card_labels).find(@card.id)
    @labels = @card.board.labels.ordered
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    @card_label.destroy
    @card   = Card.includes(:card_labels).find(@card.id)
    @labels = @card.board.labels.ordered
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  private

  def set_card
    @card = Card.accessible_to(current_user).find(params[:card_id])
  end

  def set_card_label
    @card_label = CardLabel.accessible_to(current_user).find(params[:id])
    @card = @card_label.card
  end
end
