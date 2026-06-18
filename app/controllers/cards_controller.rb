class CardsController < ApplicationController
  before_action :set_list, only: %i[create]
  before_action :set_card, only: %i[show update destroy move]

  def show
    authorize @card
    @board         = @card.board
    @checklists    = @card.checklists.includes(:checklist_items)
    @comments      = @card.comments.includes(:user)
    @labels        = @board.labels.ordered
    @board_members = @board.members
    @board_lists   = @board.lists.where(archived_at: nil).order(:position)
    @card.card_labels.load
    @card.card_memberships.load

    unless turbo_frame_request?
      # Direct page load: render board with card modal pre-opened
      @lists               = @board.lists.includes(cards: [ :labels, :members, :checklists ])
      @pending_invitations = @board.invitations.active
      @open_card           = @card
      render "boards/show"
    end
  end

  def create
    @card = @list.cards.new(card_params)
    @card.board = @list.board
    authorize @card

    respond_to do |format|
      if @card.save
        format.turbo_stream
        format.html { redirect_to board_path(@list.board) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_card_form_#{@list.id}", partial: "cards/form", locals: { card: @card, list: @list }) }
        format.html { redirect_to board_path(@list.board) }
      end
    end
  end

  def update
    authorize @card
    @old_list_id = @card.list_id
    if card_params[:list_id].present? && card_params[:list_id].to_i != @card.list_id
      new_list = @card.board.lists.find(card_params[:list_id])
      @card.move_to_list!(new_list)
    else
      @card.updated_by = current_user
      @card.update(card_params.except(:list_id))
    end
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @card }
    end
  end

  def destroy
    authorize @card
    @card.archive!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("card_#{@card.id}"),
          turbo_stream.update("card_modal", "")
        ]
      end
      format.html { redirect_to board_path(@card.board) }
    end
  end

  def move
    authorize @card
    new_list = @card.board.lists.find(params[:list_id])
    @card.move_to_list!(new_list, params[:position])
    head :ok
  end

  private

  def set_list
    @list = List.find(params[:list_id])
    authorize @list.board, :show?
  end

  def set_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:title, :description, :due_date, :due_completed, :cover_color, :list_id)
  end
end
