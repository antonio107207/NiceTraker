class BoardPolicy < ApplicationPolicy
  def show?          = can_view?
  def create?        = workspace_member?
  def edit?          = board_admin?
  def update?        = board_admin?
  def destroy?       = board_admin?
  def invite?        = board_admin?
  def remove_member? = board_admin?

  # Write actions on content — observer cannot perform these
  def manage_lists?   = board_contributor?
  def manage_cards?   = board_contributor?
  def create_comment? = board_contributor?
  def log_time?       = board_contributor?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:board_memberships)
           .where(board_memberships: { user: user })
           .or(scope.where(visibility: :public_board))
    end
  end

  private

  def can_view?
    record.public_board? || board_member?
  end

  # Any membership (admin + member + observer)
  def board_member?
    board_membership.present?
  end

  # Admin only
  def board_admin?
    board_membership&.admin?
  end

  # Admin or member — NOT observer (read-only)
  def board_contributor?
    board_membership&.admin? || board_membership&.member?
  end

  def board_membership
    @board_membership ||= record.board_memberships.find_by(user: user)
  end

  def workspace_member?
    record.workspace.workspace_memberships.exists?(user: user)
  end
end
