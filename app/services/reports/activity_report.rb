module Reports
  class ActivityReport
    attr_reader :results

    def initialize(board_ids:, date_range:, users_scope:, user_id: nil)
      @board_ids   = board_ids
      @date_range  = date_range
      @users_scope = users_scope
      @user_id     = user_id
    end

    def call
      users = @user_id ? @users_scope.where(id: @user_id) : @users_scope

      @results = users.map do |user|
        time = TimeEntry.joins(card: :board)
                        .where(boards: { id: @board_ids }, user_id: user.id)
                        .where(logged_at: @date_range).sum(:minutes)

        cards = CardMembership.joins(card: :board)
                              .where(boards: { id: @board_ids }, user_id: user.id)
                              .where(cards: { archived_at: nil }).count

        done = CardMembership.joins(card: :board)
                             .where(boards: { id: @board_ids }, user_id: user.id)
                             .where(cards: { due_completed: true }).count

        cmts = Comment.joins(card: :board)
                      .where(boards: { id: @board_ids }, user_id: user.id)
                      .where(created_at: @date_range).count

        { user: user, time_minutes: time, cards_assigned: cards, cards_done: done, comments: cmts }
      end.sort_by { |r| -r[:time_minutes] }

      self
    end
  end
end
