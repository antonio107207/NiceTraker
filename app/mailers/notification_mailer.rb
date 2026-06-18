class NotificationMailer < ApplicationMailer
  def notify(notification)
    @notification = notification
    @actor        = notification.actor
    @recipient    = notification.recipient
    @card         = notification.card

    subject = I18n.t("notifications.email_subjects.#{notification.action_type}",
                     actor: @actor.display_name, card: @card.title)

    mail(to: @recipient.email, subject: subject)
  end
end
