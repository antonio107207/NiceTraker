class CardRelationPolicy < ApplicationPolicy
  def create?  = board_policy.manage_cards?
  def destroy? = board_policy.manage_cards?

  private

  def board_policy
    @board_policy ||= BoardPolicy.new(user, record.card.board)
  end
end
