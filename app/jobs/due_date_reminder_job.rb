class DueDateReminderJob < ApplicationJob
  queue_as :default

  def perform
    cards = Card.active
                .where.not(due_date: nil)
                .where(due_completed: false)
                .where(due_date: Time.current..24.hours.from_now)
                .includes(:members, :board)

    cards.each do |card|
      card.members.each do |member|
        ReminderMailer.due_date(card, member).deliver_later
      end
    end
  end
end
