class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github gitlab]

  has_many :workspace_memberships, dependent: :destroy
  has_many :workspaces, through: :workspace_memberships
  has_many :board_memberships, dependent: :destroy
  has_many :boards, through: :board_memberships
  has_many :owned_workspaces, class_name: "Workspace", foreign_key: :owner_id, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true, allow_blank: true
  validates :email, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    # 1. Вже прив'язаний OAuth акаунт
    user = find_by(provider: auth.provider, uid: auth.uid)

    # 2. Існуючий email/password акаунт — прив'язати OAuth
    user ||= find_by(email: auth.info.email)

    # 3. Новий користувач
    user ||= new(email: auth.info.email, password: Devise.friendly_token[0, 20])

    user.provider   = auth.provider
    user.uid        = auth.uid
    user.name       = user.name.presence || auth.info.name || auth.info.nickname || auth.info.email.split("@").first
    user.avatar_url = user.avatar_url.presence || auth.info.image
    user.save!
    user
  end

  def display_name
    name.presence || email.split("@").first
  end

  def initials
    parts = display_name.split
    if parts.size >= 2
      "#{parts.first[0]}#{parts.last[0]}".upcase
    else
      display_name[0, 2].upcase
    end
  end
end
