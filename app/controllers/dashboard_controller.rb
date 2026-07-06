class DashboardController < ApplicationController
  def index
    @workspaces          = current_user.workspaces.active.includes(:boards).order(:name)
    @archived_workspaces = current_user.workspaces.archived.order(archived_at: :desc)
    @recent_boards       = current_user.boards.active.in_active_workspace.order(updated_at: :desc).limit(8)
  end
end
