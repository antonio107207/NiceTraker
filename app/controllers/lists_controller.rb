class ListsController < ApplicationController
  before_action :set_list,  only: %i[update destroy move]
  before_action :set_board

  def create
    @list = @board.lists.new(list_params)
    authorize @list

    respond_to do |format|
      if @list.save
        format.turbo_stream
        format.html { redirect_to board_path(@board) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_list_form", partial: "lists/form", locals: { list: @list, board: @board }) }
        format.html { redirect_to board_path(@board) }
      end
    end
  end

  def update
    authorize @list
    @list.update(list_params)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to board_path(@board) }
    end
  end

  def destroy
    authorize @list
    @list.archive!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("list_#{@list.id}") }
      format.html { redirect_to board_path(@board) }
    end
  end

  def move
    authorize @list
    @list.insert_at(params[:position].to_i)
    head :ok
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def set_board
    if params[:board_id].present?
      @board = Board.find(params[:board_id])
    elsif @list
      @board = @list.board
    end
    authorize @board, :show?
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
