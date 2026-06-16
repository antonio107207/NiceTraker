class Workspace < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :workspace_memberships, dependent: :destroy
  has_many :members, through: :workspace_memberships, source: :user
  has_many :boards, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  before_validation :generate_slug, on: :create

  def member?(user)
    workspace_memberships.exists?(user: user)
  end

  def admin?(user)
    workspace_memberships.admin.exists?(user: user)
  end

  private

  def generate_slug
    return if slug.present?
    base = name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    self.slug = base
    counter = 1
    while Workspace.where(slug: self.slug).exists?
      self.slug = "#{base}-#{counter}"
      counter += 1
    end
  end
end
