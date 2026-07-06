class Portal::DashboardController < Portal::BaseController
  def index
    @stats = {
      users:        User.count,
      super_admins: User.super_admins.count,
      workspaces:   Workspace.count,
      boards:       Board.count,
      cards:        Card.count,
      comments:     Comment.count
    }
    @recent_users  = User.order(created_at: :desc).limit(8)
    @recent_boards = Board.includes(:workspace).order(created_at: :desc).limit(8)
  end
end
