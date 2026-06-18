module Reports
  class CardsReport
    attr_reader :results, :summary

    def initialize(board_ids:, date_range:, user_id: nil, status: "active")
      @board_ids  = board_ids
      @date_range = date_range
      @user_id    = user_id
      @status     = status
    end

    def call
      scope = Card.includes(:board, :list, :members, :labels, :time_entries,
                             checklists: :checklist_items)
                  .joins(:board)
                  .where(boards: { id: @board_ids })
                  .where(created_at: @date_range)

      scope = scope.joins(:card_memberships)
                   .where(card_memberships: { user_id: @user_id }) if @user_id

      scope = apply_status(scope)

      @results = scope.order(created_at: :desc).limit(500)
      @summary = {
        total:    @results.size,
        overdue:  @results.count { |c| c.due_date && c.due_date < Time.current && !c.due_completed },
        time_min: @results.sum { |c| c.time_entries.sum(&:minutes) }
      }
      self
    end

    private

    def apply_status(scope)
      case @status
      when "overdue"   then scope.where(archived_at: nil).where("due_date < ? AND due_completed = false", Time.current)
      when "completed" then scope.where(due_completed: true)
      when "archived"  then scope.where.not(archived_at: nil)
      else                  scope.where(archived_at: nil)
      end
    end
  end
end
