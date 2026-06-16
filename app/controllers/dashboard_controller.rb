class DashboardController < ApplicationController
  def index
    @workspaces = current_user.workspaces.includes(:boards).order(:name)
    @recent_boards = current_user.boards.active.order(updated_at: :desc).limit(8)
  end
end
