class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :owner, class_name: "User"
  belongs_to :board

  validates :key, presence: true

  scope :recent, -> { order(created_at: :desc).limit(50) }

  def self.log(key:, owner:, board:, trackable:, params: {})
    create!(key: key, owner: owner, board: board, trackable: trackable, parameters: params)
  end
end
