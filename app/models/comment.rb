class Comment < ApplicationRecord
  belongs_to :card
  belongs_to :user

  validates :body, presence: true
end
