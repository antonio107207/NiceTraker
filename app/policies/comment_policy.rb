class CommentPolicy < ApplicationPolicy
  def create?  = board_policy.create_comment?
  def update?  = own? && board_policy.create_comment?
  def destroy? = own? || board_admin?

  private

  def board_policy
    @board_policy ||= BoardPolicy.new(user, record.card.board)
  end

  def own?
    record.user == user
  end

  def board_admin?
    record.card.board.board_memberships.find_by(user: user)&.admin?
  end
end
