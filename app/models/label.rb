class Label < ApplicationRecord
  belongs_to :board
  has_many :card_labels, dependent: :destroy
  has_many :cards, through: :card_labels

  COLORS = %w[
    #ef4444 #f97316 #eab308 #22c55e
    #14b8a6 #3b82f6 #8b5cf6 #ec4899
    #6b7280 #1e293b
  ].freeze

  validates :color, presence: true, inclusion: { in: COLORS }
  validates :name, length: { maximum: 30 }

  scope :ordered, -> { order(:name) }
end
