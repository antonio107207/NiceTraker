class CardMembershipsController < ApplicationController
  before_action :set_card,       only: %i[create]
  before_action :set_membership, only: %i[destroy]

  def create
    member     = @card.board.members.find(params[:user_id])
    membership = @card.card_memberships.find_or_create_by!(user: member)
    was_new    = membership.previously_new_record?
    @card          = Card.includes(:card_memberships).find(@card.id)
    @board_members = @card.board.members
    @card.notify_assignment!(member, current_user, :assigned) if was_new && member != current_user
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    member = @membership.user
    @membership.destroy
    @card          = Card.includes(:card_memberships).find(@card.id)
    @board_members = @card.board.members
    @card.notify_assignment!(member, current_user, :unassigned) if member != current_user
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  private

  def set_card
    @card = Card.accessible_to(current_user).find(params[:card_id])
  end

  def set_membership
    @membership = CardMembership.accessible_to(current_user).find(params[:id])
    @card = @membership.card
  end
end
