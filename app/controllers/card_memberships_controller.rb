class CardMembershipsController < ApplicationController
  before_action :set_card,       only: %i[create]
  before_action :set_membership, only: %i[destroy]

  def create
    member = @card.board.members.find(params[:user_id])
    @card.card_memberships.find_or_create_by!(user: member)
    @card          = Card.includes(:card_memberships).find(@card.id)
    @board_members = @card.board.members
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    @membership.destroy
    @card          = Card.includes(:card_memberships).find(@card.id)
    @board_members = @card.board.members
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  private

  def set_card
    @card = Card.joins(:board)
                .where(boards: { id: current_user.boards.select(:id) })
                .find(params[:card_id])
  end

  def set_membership
    @membership = CardMembership.joins(card: :board)
                                .where(boards: { id: current_user.boards.select(:id) })
                                .find(params[:id])
    @card = @membership.card
  end
end
