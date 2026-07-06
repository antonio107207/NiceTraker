class Portal::WorkspacesController < Portal::BaseController
  before_action :set_workspace, only: %i[show destroy]

  def index
    @workspaces = Workspace.includes(:owner).order(created_at: :desc)
    @workspaces = @workspaces.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
  end

  def show
    @members = @workspace.workspace_memberships.includes(:user)
    @boards  = @workspace.boards.order(created_at: :desc)
  end

  def destroy
    @workspace.destroy!
    redirect_to portal_workspaces_path, notice: t("portal.workspaces.deleted")
  end

  private

  def set_workspace
    @workspace = Workspace.find(params[:id])
  end
end
