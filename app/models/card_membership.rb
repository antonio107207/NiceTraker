class CardMembership < ApplicationRecord
  belongs_to :card
  belongs_to :user

  scope :accessible_to, ->(user) { joins(card: :board).where(boards: { id: user.boards.select(:id) }) }
end
