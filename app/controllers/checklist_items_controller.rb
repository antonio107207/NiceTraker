class ChecklistItemsController < ApplicationController
  before_action :set_checklist, only: %i[create]
  before_action :set_item,      only: %i[update destroy]

  def create
    @item = @checklist.checklist_items.create!(checklist_item_params)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to root_path }
    end
  end

  def update
    @item.update!(completed: params[:checklist_item][:completed] == "1")
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to root_path }
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to root_path }
    end
  end

  private

  def set_checklist
    @checklist = Checklist.joins(card: :board)
                          .where(boards: { id: current_user.boards.select(:id) })
                          .find(params[:checklist_id])
  end

  def set_item
    @item = ChecklistItem.joins(checklist: { card: :board })
                         .where(boards: { id: current_user.boards.select(:id) })
                         .find(params[:id])
    @checklist = @item.checklist
  end

  def checklist_item_params
    params.require(:checklist_item).permit(:title)
  end
end
