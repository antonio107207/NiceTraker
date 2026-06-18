class CardRelationsController < ApplicationController
  before_action :set_card,     only: %i[search create]
  before_action :set_relation, only: %i[destroy]

  def search
    @relation_type = params[:relation_type].presence || "relates_to"
    excluded = @card.card_relations.pluck(:related_card_id) + [ @card.id ]
    @results = CardSearchQuery.new(
      query:        params[:q],
      scope:        accessible_cards,
      excluded_ids: excluded
    ).results
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
    @relation = CardRelation.accessible_to(current_user).find(params[:id])
    @card = @relation.card
  end

  def accessible_cards
    Card.accessible_to(current_user)
  end
end
