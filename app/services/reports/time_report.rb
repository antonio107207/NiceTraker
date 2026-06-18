module Reports
  class TimeReport
    attr_reader :results, :total_minutes, :by_user

    def initialize(board_ids:, date_range:, user_id: nil)
      @board_ids  = board_ids
      @date_range = date_range
      @user_id    = user_id
    end

    def call
      scope = TimeEntry.includes(:user, card: [ :board, :list ])
                       .joins(card: :board)
                       .where(boards: { id: @board_ids })
                       .where(logged_at: @date_range)

      scope = scope.where(user_id: @user_id) if @user_id

      @results       = scope.order(logged_at: :desc).limit(500)
      @total_minutes = @results.sum(&:minutes)
      @by_user       = @results.group_by(&:user)
                               .transform_values { |entries| entries.sum(&:minutes) }
                               .sort_by { |_u, m| -m }
      self
    end
  end
end
