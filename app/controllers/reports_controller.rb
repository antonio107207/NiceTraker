require "csv"

class ReportsController < ApplicationController
  helper_method :fmt_minutes

  def index
    setup_filters
    generate_report if params[:generate].present?
  end

  def export
    setup_filters
    generate_report
    respond_to do |format|
      format.csv do
        send_data build_csv, filename: "report_#{@report_type}_#{Date.today}.csv",
                             type: "text/csv; charset=utf-8"
      end
    end
  end

  private

  # ── Setup ────────────────────────────────────────────────────────────

  def setup_filters
    @boards = current_user.boards.order(:name)
    @users  = User.joins(:board_memberships)
                  .where(board_memberships: { board_id: @boards.select(:id) })
                  .distinct.order(:name)

    @report_type = params[:report_type].presence || "cards"
    @date_from   = parse_date(params[:date_from]) || 30.days.ago.to_date
    @date_to     = parse_date(params[:date_to])   || Date.today
    @board_id    = params[:board_id].presence
    @user_id     = params[:user_id].presence
    @status      = params[:status].presence || "active"

    @board_ids = @board_id ? @boards.where(id: @board_id).select(:id) : @boards.select(:id)
  end

  def generate_report
    send(:"report_#{@report_type}")
  rescue NameError
    nil
  end

  # ── Report types ─────────────────────────────────────────────────────

  def report_cards
    scope = Card.includes(:board, :list, :members, :labels, :time_entries,
                           checklists: :checklist_items)
                .joins(:board)
                .where(boards: { id: @board_ids })
                .where(created_at: date_range)

    scope = scope.joins(:card_memberships)
                 .where(card_memberships: { user_id: @user_id }) if @user_id

    scope = case @status
    when "overdue"   then scope.where(archived_at: nil).where("due_date < ? AND due_completed = false", Time.current)
    when "completed" then scope.where(due_completed: true)
    when "archived"  then scope.where.not(archived_at: nil)
    else                  scope.where(archived_at: nil)
    end

    @results = scope.order(created_at: :desc).limit(500)

    @summary = {
      total:    @results.size,
      overdue:  @results.count { |c| c.due_date && c.due_date < Time.current && !c.due_completed },
      time_min: @results.sum { |c| c.time_entries.sum(&:minutes) }
    }
  end

  def report_time
    scope = TimeEntry.includes(:user, card: [ :board, :list ])
                     .joins(card: :board)
                     .where(boards: { id: @board_ids })
                     .where(logged_at: date_range)

    scope = scope.where(user_id: @user_id) if @user_id
    @results = scope.order(logged_at: :desc).limit(500)

    @total_minutes = @results.sum(&:minutes)
    @by_user = @results.group_by(&:user).transform_values { |entries| entries.sum(&:minutes) }
                       .sort_by { |_u, m| -m }
  end

  def report_activity
    users = @user_id ? @users.where(id: @user_id) : @users

    @results = users.map do |user|
      time = TimeEntry.joins(card: :board)
                      .where(boards: { id: @board_ids }, user_id: user.id)
                      .where(logged_at: date_range).sum(:minutes)

      cards = CardMembership.joins(card: :board)
                            .where(boards: { id: @board_ids }, user_id: user.id)
                            .where(cards: { archived_at: nil }).count

      done = CardMembership.joins(card: :board)
                           .where(boards: { id: @board_ids }, user_id: user.id)
                           .where(cards: { due_completed: true }).count

      cmts = Comment.joins(card: :board)
                    .where(boards: { id: @board_ids }, user_id: user.id)
                    .where(created_at: date_range).count

      { user: user, time_minutes: time, cards_assigned: cards, cards_done: done, comments: cmts }
    end.sort_by { |r| -r[:time_minutes] }
  end

  def report_boards
    boards = Board.where(id: @board_ids)

    @results = boards.map do |board|
      cards   = board.cards
      total   = cards.count
      active  = cards.where(archived_at: nil).count
      overdue = cards.where(archived_at: nil)
                     .where("due_date < ? AND due_completed = false", Time.current).count
      done    = cards.where(due_completed: true).count
      time    = TimeEntry.joins(:card).where(cards: { board_id: board.id })
                         .where(logged_at: date_range).sum(:minutes)
      members = board.members.count

      { board: board, total: total, active: active, overdue: overdue,
        done: done, time_minutes: time, members: members }
    end.sort_by { |r| -r[:total] }
  end

  # ── CSV ──────────────────────────────────────────────────────────────

  def build_csv
    CSV.generate(headers: true) do |csv|
      case @report_type
      when "cards"
        csv << %w[ID Title Board List Assignees Labels Due\ Date Created Time\ Logged Status]
        @results.each do |c|
          csv << [
            c.identifier, c.title, c.board.name, c.list.name,
            c.members.map(&:display_name).join("; "),
            c.labels.map(&:name).join("; "),
            c.due_date&.strftime("%Y-%m-%d"),
            c.created_at.strftime("%Y-%m-%d"),
            fmt_minutes(c.time_entries.sum(&:minutes)),
            card_status(c)
          ]
        end

      when "time"
        csv << %w[Date User Card Board Duration Note]
        @results.each do |e|
          csv << [
            e.logged_at.strftime("%Y-%m-%d"), e.user.display_name,
            e.card.identifier, e.card.board.name,
            fmt_minutes(e.minutes), e.description
          ]
        end

      when "activity"
        csv << [ "Developer", "Cards Assigned", "Cards Done", "Time Logged", "Comments" ]
        @results.each do |r|
          csv << [ r[:user].display_name, r[:cards_assigned], r[:cards_done],
                  fmt_minutes(r[:time_minutes]), r[:comments] ]
        end

      when "boards"
        csv << %w[Board Members Total\ Cards Active Overdue Completed Time\ Logged]
        @results.each do |r|
          csv << [ r[:board].name, r[:members], r[:total], r[:active],
                  r[:overdue], r[:done], fmt_minutes(r[:time_minutes]) ]
        end
      end
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────────

  def fmt_minutes(min)
    return "—" if min.nil? || min.zero?
    h, m = min.to_i.divmod(60)
    parts = [ h > 0 ? "#{h}h" : nil, m > 0 ? "#{m}m" : nil ].compact
    parts.join(" ")
  end

  def card_status(card)
    return "Archived"  if card.archived_at?
    return "Completed" if card.due_completed?
    return "Overdue"   if card.due_date && card.due_date < Time.current
    "Active"
  end

  def date_range
    @date_from.beginning_of_day..@date_to.end_of_day
  end

  def parse_date(str)
    Date.parse(str) rescue nil
  end
end
