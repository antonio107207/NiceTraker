class ChecklistItemsController < ApplicationController
  before_action :set_checklist, only: %i[create]
  before_action :set_item,      only: %i[update destroy]
  before_action :set_card

  def create
    @item = @checklist.checklist_items.create!(checklist_item_params)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to root_path }
    end
  end

  def update
    if params[:checklist_item].key?(:title)
      @item.update!(title: checklist_item_params[:title])
    else
      @item.update!(completed: params[:checklist_item][:completed] == "1")
    end
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
    @checklist = Checklist.accessible_to(current_user).find(params[:checklist_id])
  end

  def set_item
    @item = ChecklistItem.accessible_to(current_user).find(params[:id])
    @checklist = @item.checklist
  end

  def set_card
    @card = @checklist.card
  end

  def checklist_item_params
    params.require(:checklist_item).permit(:title, :completed)
  end
end
