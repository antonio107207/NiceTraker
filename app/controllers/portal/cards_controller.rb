class Portal::CardsController < Portal::BaseController
  before_action :set_card, only: %i[show destroy]

  def index
    @cards = Card.includes(:board, :list).order(created_at: :desc)
    @cards = @cards.where("cards.title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
  end

  def show
    @comments    = @card.comments.includes(:user).order(created_at: :desc)
    @activities  = @card.activities.includes(:owner).order(created_at: :desc).limit(20)
  end

  def destroy
    @card.destroy!
    redirect_to portal_cards_path, notice: t("portal.cards.deleted")
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end
end
