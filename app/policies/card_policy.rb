class CardPolicy < ApplicationPolicy
  def show?    = board_policy.show?
  def create?  = board_policy.manage_cards?
  def edit?    = board_member_or_assigned?
  def update?  = board_member_or_assigned?
  def destroy? = board_policy.manage_cards?
  def move?    = board_policy.manage_cards?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end

  private

  def board_policy
    @board_policy ||= BoardPolicy.new(user, record.board)
  end

  def board_member_or_assigned?
    board_policy.manage_cards? || record.members.include?(user)
  end
end
