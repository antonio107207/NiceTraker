class CardRelation < ApplicationRecord
  INVERSE = {
    "relates_to" => "relates_to",
    "parent"     => "child",
    "child"      => "parent",
    "blocks"     => "blocked_by",
    "blocked_by" => "blocks",
    "duplicates" => "duplicates"
  }.freeze

  TYPES = INVERSE.keys.freeze

  belongs_to :card
  belongs_to :related_card, class_name: "Card"

  scope :accessible_to, ->(user) { joins(card: :board).where(boards: { id: user.boards.select(:id) }) }

  validates :relation_type, inclusion: { in: TYPES }
  validates :related_card_id, uniqueness: { scope: %i[card_id relation_type] }
  validate  :not_self_referential

  after_create  :sync_inverse_create
  after_destroy :sync_inverse_destroy

  private

  def not_self_referential
    errors.add(:related_card, :invalid) if card_id == related_card_id
  end

  def sync_inverse_create
    CardRelation.find_or_create_by!(
      card_id:         related_card_id,
      related_card_id: card_id,
      relation_type:   INVERSE[relation_type]
    )
  end

  def sync_inverse_destroy
    CardRelation.find_by(
      card_id:         related_card_id,
      related_card_id: card_id,
      relation_type:   INVERSE[relation_type]
    )&.destroy
  end
end
