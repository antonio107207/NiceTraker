class Comment < ApplicationRecord
  belongs_to :card
  belongs_to :user

  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :notify_mentions

  MENTION_RE = /\@\[([^\]]+)\]/

  def mentioned_names
    body.scan(MENTION_RE).flatten
  end

  def rendered_body
    body.gsub(MENTION_RE) do |_|
      name = $1
      "<span class=\"mention\">@#{ERB::Util.html_escape(name)}</span>"
    end.then { |html| simple_format(html) }
  end

  private

  def notify_mentions
    return if mentioned_names.empty?

    board_members = card.board.members.index_by(&:display_name)
    mentioned_names.uniq.each do |name|
      recipient = board_members[name]
      next unless recipient
      next if recipient == user

      Notification.create!(
        recipient:   recipient,
        actor:       user,
        notifiable:  self,
        action_type: :mentioned
      )
    end
  end
end
