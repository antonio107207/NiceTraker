class Portal::BoardsController < Portal::BaseController
  before_action :set_board, only: %i[show destroy]

  def index
    @boards = Board.includes(:workspace).order(created_at: :desc)
    @boards = @boards.where("boards.name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
  end

  def show
    @members = @board.board_memberships.includes(:user)
    @lists   = @board.all_lists.order(:position)
  end

  def destroy
    @board.destroy!
    redirect_to portal_boards_path, notice: t("portal.boards.deleted")
  end

  private

  def set_board
    @board = Board.find(params[:id])
  end
end
