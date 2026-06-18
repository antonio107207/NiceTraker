class LabelsController < ApplicationController
  before_action :set_board

  def create
    @label = @board.labels.new(label_params)
    @card  = Card.find_by(id: params.dig(:label, :card_id), board: @board)
    if @label.save
      @labels = @board.labels.ordered
      @card   = Card.includes(:card_labels).find(@card.id) if @card
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to board_path(@board) }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to board_path(@board) }
      end
    end
  end

  def destroy
    @label.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("label_row_#{@label.id}") }
      format.html { redirect_to board_path(@board) }
    end
  end

  private

  def set_board
    if params[:board_id]
      @board = current_user.boards.find(params[:board_id])
    else
      @label = Label.accessible_to(current_user).find(params[:id])
      @board = @label.board
    end
  end

  def label_params
    params.require(:label).permit(:name, :color)
  end
end
