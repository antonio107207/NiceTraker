class Board < ApplicationRecord
  belongs_to :workspace
  has_many :board_memberships, dependent: :destroy
  has_many :members, through: :board_memberships, source: :user
  has_many :lists, -> { where(archived_at: nil).order(:position) }, dependent: :destroy
  has_many :all_lists, class_name: "List", dependent: :destroy
  has_many :cards, through: :lists
  has_many :labels, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :activities, dependent: :destroy

  enum :visibility, { private_board: 0, workspace: 1, public_board: 2 }, default: :workspace

  validates :name, presence: true
  validates :key, presence: true, format: { with: /\A[A-Z0-9]{1,6}\z/ }, uniqueness: { scope: :workspace_id }

  before_validation :generate_key, on: :create

  scope :active, -> { where(archived_at: nil) }

  private

  def generate_key
    return if key.present?
    base = name.gsub(/[^A-Za-z0-9]/, "").upcase.first(5).presence || "BRD"
    candidate = base
    n = 2
    while workspace.boards.exists?(key: candidate)
      candidate = "#{base.first(4)}#{n}"
      n += 1
    end
    self.key = candidate
  end

  public

  def owner
    board_memberships.admin.first&.user
  end

  def member?(user)
    board_memberships.exists?(user: user)
  end

  def admin?(user)
    board_memberships.admin.exists?(user: user)
  end
end
