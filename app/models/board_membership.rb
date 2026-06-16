class BoardMembership < ApplicationRecord
  belongs_to :board
  belongs_to :user

  enum :role, { admin: 0, member: 1, observer: 2 }, default: :member

  validates :user_id, uniqueness: { scope: :board_id }
end
