class BoardsController < ApplicationController
  before_action :set_workspace, only: %i[new create]
  before_action :set_board,     only: %i[show edit update destroy invite archived]

  def show
    authorize @board
    @lists               = @board.lists.includes(cards: [ :labels, :members, :checklists ])
    @labels              = @board.labels
    @board_members       = @board.members
    @pending_invitations = @board.invitations.active
    @open_card           = @board.cards.find_by(id: params[:card])
    @current_membership  = @board.board_memberships.find_by(user: current_user)
  end

  def new
    @board = @workspace.boards.new
    authorize @board
  end

  def create
    @board = @workspace.boards.new(board_params)
    authorize @board

    if @board.save
      @board.board_memberships.create!(user: current_user, role: :admin)
      redirect_to board_path(@board), notice: t("flash.board_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @workspace = @board.workspace
    authorize @board
  end

  def update
    authorize @board
    if params.dig(:board, :remove_background_image) == "1"
      @board.background_image.purge if @board.background_image.attached?
    end
    if @board.update(board_params)
      redirect_to board_path(@board), notice: t("flash.board_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @board
    workspace = @board.workspace
    @board.destroy!
    redirect_to workspace, notice: t("flash.board_deleted")
  end

  def archived
    authorize @board
    @archived_cards = Card.where(board: @board).where.not(archived_at: nil).order(archived_at: :desc)
  end

  def invite
    authorize @board
    result = BoardInvitationService.call(
      board:   @board,
      email:   params[:email].to_s.strip,
      role:    params[:role].presence || "member",
      inviter: current_user
    )

    @invitation          = result.invitation
    @pending_invitations = @board.invitations.active
    @flash_type          = result.success? ? :notice : :alert
    @flash_message       = t(result.flash_key, **result.flash_params)

    respond_to do |format|
      format.html { redirect_to board_path(@board), @flash_type => @flash_message }
      format.turbo_stream { render :invite }
    end
  end

  private

  def set_workspace
    @workspace = current_user.workspaces.find(params[:workspace_id])
  end

  def set_board
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:name, :background_color, :visibility, :background_image)
  end
end
