class WorkspaceMembership < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  enum :role, { member: 1, admin: 0 }, default: :member

  validates :user_id, uniqueness: { scope: :workspace_id }
end
