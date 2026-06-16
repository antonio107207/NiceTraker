class CardRelationsController < ApplicationController
  before_action :set_card,     only: %i[search create]
  before_action :set_relation, only: %i[destroy]

  def search
    q = params[:q].to_s.strip
    @relation_type = params[:relation_type].presence || "relates_to"
    @results = []

    if q.length >= 2
      excluded = @card.card_relations.pluck(:related_card_id) + [@card.id]
      base = accessible_cards.where.not(id: excluded)

      @results = if q =~ /\A[A-Za-z0-9]+-\d+\z/
        key, num = q.upcase.split("-")
        base.joins(:board).where(boards: { key: key }, number: num.to_i).limit(5)
      else
        base.where("cards.title ILIKE ?", "%#{q}%").limit(8)
      end
    end

    render layout: false
  end

  def create
    authorize CardRelation.new(card: @card), :create?
    related = accessible_cards.where.not(id: @card.id)
                               .find(params.dig(:card_relation, :related_card_id))
    type = params.dig(:card_relation, :relation_type).presence || "relates_to"
    @relation = @card.card_relations.find_or_create_by!(related_card: related, relation_type: type)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    authorize @relation
    @relation.destroy!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  private

  def set_card
    @card = accessible_cards.find(params[:card_id])
  end

  def set_relation
    @relation = CardRelation.joins(card: :board)
                            .where(boards: { id: current_user.boards.select(:id) })
                            .find(params[:id])
    @card = @relation.card
  end

  def accessible_cards
    Card.joins(:board).where(boards: { id: current_user.boards.select(:id) })
  end
end
