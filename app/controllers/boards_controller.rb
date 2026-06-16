class BoardsController < ApplicationController
  before_action :set_workspace, only: %i[new create]
  before_action :set_board,     only: %i[show edit update destroy invite]

  def show
    authorize @board
    @lists               = @board.lists.includes(cards: [:labels, :members, :checklists])
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
    authorize @board
  end

  def update
    authorize @board
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

  def invite
    authorize @board
    email = params[:email].to_s.strip
    role  = params[:role].presence || "member"

    if @board.members.exists?(email: email)
      msg = t("flash.already_member", email: email)
      respond_to do |format|
        format.html { redirect_to board_path(@board), alert: msg }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_container", partial: "layouts/flash", locals: { alert: msg }) }
      end
      return
    end

    invitation = @board.invitations.find_or_initialize_by(email: email, status: :pending)
    invitation.assign_attributes(inviter: current_user, role: role)
    invitation.save!

    InvitationMailer.invite(invitation).deliver_later

    respond_to do |format|
      format.html { redirect_to board_path(@board), notice: t("flash.invitation_sent", email: email) }
      format.turbo_stream
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
    params.require(:board).permit(:name, :background_color, :visibility)
  end
end
