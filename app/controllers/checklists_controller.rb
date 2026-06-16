class ChecklistsController < ApplicationController
  before_action :set_card,      only: %i[create]
  before_action :set_checklist, only: %i[destroy]

  def create
    title = checklist_params[:title].presence || "Checklist"
    @checklist = @card.checklists.create!(title: title)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @card }
    end
  end

  def destroy
    @checklist.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("checklist_#{@checklist.id}") }
      format.html { redirect_to @card }
    end
  end

  private

  def set_card
    @card = Card.joins(:board).where(boards: { id: current_user.boards.select(:id) }).find(params[:card_id])
  end

  def set_checklist
    @checklist = Checklist.joins(card: :board).where(boards: { id: current_user.boards.select(:id) }).find(params[:id])
    @card = @checklist.card
  end

  def checklist_params
    params.require(:checklist).permit(:title)
  end
end
