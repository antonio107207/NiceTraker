class CommentsController < ApplicationController
  before_action :set_card,    only: %i[create]
  before_action :set_comment, only: %i[update destroy]

  def create
    @comment = @card.comments.new(comment_params.merge(user: current_user))
    authorize @comment
    @comment.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @card }
    end
  end

  def update
    authorize @comment
    @comment.update!(comment_params)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    authorize @comment
    @comment.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("comment_#{@comment.id}") }
      format.html { redirect_to @card }
    end
  end

  private

  def set_card
    @card = Card.joins(:board).where(boards: { id: current_user.boards.select(:id) }).find(params[:card_id])
  end

  def set_comment
    @comment = Comment.joins(card: :board)
                      .where(boards: { id: current_user.boards.select(:id) })
                      .find(params[:id])
    @card = @comment.card
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
