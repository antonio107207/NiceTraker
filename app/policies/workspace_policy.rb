class WorkspacePolicy < ApplicationPolicy
  def show?          = member?
  def edit?          = admin?
  def update?        = admin?
  def destroy?       = admin?
  def create?        = true
  def remove_member? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:workspace_memberships).where(workspace_memberships: { user: user })
    end
  end

  private

  def admin?  = workspace_membership&.admin?
  def member? = workspace_membership.present?

  def workspace_membership
    @workspace_membership ||= record.workspace_memberships.find_by(user: user)
  end
end
