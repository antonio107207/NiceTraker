module Reports
  class BoardsReport
    attr_reader :results

    def initialize(board_ids:, date_range:)
      @board_ids  = board_ids
      @date_range = date_range
    end

    def call
      boards = Board.where(id: @board_ids)

      @results = boards.map do |board|
        cards   = board.cards
        time    = TimeEntry.joins(:card).where(cards: { board_id: board.id })
                           .where(logged_at: @date_range).sum(:minutes)

        { board:   board,
          total:   cards.count,
          active:  cards.where(archived_at: nil).count,
          overdue: cards.where(archived_at: nil)
                        .where("due_date < ? AND due_completed = false", Time.current).count,
          done:    cards.where(due_completed: true).count,
          time_minutes: time,
          members: board.members.count }
      end.sort_by { |r| -r[:total] }

      self
    end
  end
end
