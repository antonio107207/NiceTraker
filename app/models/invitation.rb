class Invitation < ApplicationRecord
  belongs_to :board
  belongs_to :inviter, class_name: "User"

  enum :role,   { admin: 0, member: 1, observer: 2 }, default: :member
  enum :status, { pending: 0, accepted: 1, declined: 2 }, default: :pending

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :email, uniqueness: { scope: :board_id, conditions: -> { pending } }

  before_validation :generate_token, on: :create

  scope :active, -> { pending.where("expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def accept!(user)
    return false if expired? || !pending?
    ActiveRecord::Base.transaction do
      board.board_memberships.find_or_create_by!(user: user) do |m|
        m.role = role
      end
      accepted!
    end
    true
  end

  private

  def generate_token
    self.token     ||= SecureRandom.urlsafe_base64(32)
    self.expires_at ||= 7.days.from_now
  end
end
