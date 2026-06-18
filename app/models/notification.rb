class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor,     class_name: "User"
  belongs_to :notifiable, polymorphic: true

  enum :action_type, { mentioned: 0, assigned: 1, unassigned: 2, card_updated: 3 }

  scope :unread,  -> { where(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc).limit(30) }

  after_create_commit :broadcast_to_recipient
  after_create_commit :send_email

  def card
    notifiable.is_a?(Comment) ? notifiable.card : notifiable
  end

  def message
    I18n.t("notifications.#{action_type}", card: card.title)
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  def read?
    read_at.present?
  end

  private

  def broadcast_to_recipient
    broadcast_prepend_to(
      "notifications_user_#{recipient_id}",
      target: "notifications_list",
      partial: "notifications/notification",
      locals: { notification: self }
    )
    broadcast_replace_to(
      "notifications_user_#{recipient_id}",
      target: "notification_badge",
      partial: "notifications/badge",
      locals: { count: recipient.notifications.unread.count }
    )
  end

  def send_email
    NotificationMailer.notify(self).deliver_later
  end
end
