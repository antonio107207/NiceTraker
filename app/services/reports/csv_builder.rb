require "csv"

module Reports
  class CsvBuilder
    def initialize(report_type:, results:, summary: nil)
      @report_type = report_type
      @results     = results
      @summary     = summary
    end

    def call
      CSV.generate(headers: true) do |csv|
        send(:"build_#{@report_type}", csv)
      end
    end

    private

    def build_cards(csv)
      csv << %w[ID Title Board List Assignees Labels Due\ Date Created Time\ Logged Status]
      @results.each do |c|
        p = CardPresenter.new(c)
        csv << [
          p.identifier, p.title, p.board.name, p.list.name,
          p.members.map(&:display_name).join("; "),
          p.labels.map(&:name).join("; "),
          p.due_date&.strftime("%Y-%m-%d"),
          p.created_at.strftime("%Y-%m-%d"),
          fmt_minutes(p.time_entries.sum(&:minutes)),
          p.status_label
        ]
      end
    end

    def build_time(csv)
      csv << %w[Date User Card Board Duration Note]
      @results.each do |e|
        csv << [
          e.logged_at.strftime("%Y-%m-%d"), e.user.display_name,
          e.card.identifier, e.card.board.name,
          fmt_minutes(e.minutes), e.description
        ]
      end
    end

    def build_activity(csv)
      csv << [ "Developer", "Cards Assigned", "Cards Done", "Time Logged", "Comments" ]
      @results.each do |r|
        csv << [ r[:user].display_name, r[:cards_assigned], r[:cards_done],
                 fmt_minutes(r[:time_minutes]), r[:comments] ]
      end
    end

    def build_boards(csv)
      csv << %w[Board Members Total\ Cards Active Overdue Completed Time\ Logged]
      @results.each do |r|
        csv << [ r[:board].name, r[:members], r[:total], r[:active],
                 r[:overdue], r[:done], fmt_minutes(r[:time_minutes]) ]
      end
    end

    def fmt_minutes(min)
      return "—" if min.nil? || min.zero?
      h, m = min.to_i.divmod(60)
      [ (h > 0 ? "#{h}h" : nil), (m > 0 ? "#{m}m" : nil) ].compact.join(" ")
    end
  end
end
