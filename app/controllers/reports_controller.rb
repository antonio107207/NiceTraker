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
        csv = Reports::CsvBuilder.new(report_type: @report_type, results: @results).call
        send_data csv, filename: "report_#{@report_type}_#{Date.today}.csv",
                       type: "text/csv; charset=utf-8"
      end
    end
  end

  private

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
    range = @date_from.beginning_of_day..@date_to.end_of_day

    report = case @report_type
    when "cards"    then Reports::CardsReport.new(board_ids: @board_ids, date_range: range, user_id: @user_id, status: @status)
    when "time"     then Reports::TimeReport.new(board_ids: @board_ids, date_range: range, user_id: @user_id)
    when "activity" then Reports::ActivityReport.new(board_ids: @board_ids, date_range: range, users_scope: @users, user_id: @user_id)
    when "boards"   then Reports::BoardsReport.new(board_ids: @board_ids, date_range: range)
    end

    return unless report

    report.call
    @results       = report.results
    @summary       = report.respond_to?(:summary)       ? report.summary       : nil
    @total_minutes = report.respond_to?(:total_minutes)  ? report.total_minutes  : nil
    @by_user       = report.respond_to?(:by_user)        ? report.by_user        : nil
  end

  def fmt_minutes(min)
    return "—" if min.nil? || min.zero?
    h, m = min.to_i.divmod(60)
    [ (h > 0 ? "#{h}h" : nil), (m > 0 ? "#{m}m" : nil) ].compact.join(" ")
  end

  def parse_date(str)
    Date.parse(str) rescue nil
  end
end
