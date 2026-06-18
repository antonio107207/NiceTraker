class ReminderMailer < ApplicationMailer
  def due_date(card, user)
    @card  = card
    @user  = user
    @board = card.board

    mail(
      to:      user.email,
      subject: I18n.t("reminder_mailer.due_date_subject",
                       card: card.title,
                       date: card.due_date.strftime("%d.%m"))
    )
  end
end
