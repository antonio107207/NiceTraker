class TimeEntry < ApplicationRecord
  belongs_to :card
  belongs_to :user

  validates :minutes, presence: true, numericality: { greater_than: 0, only_integer: true }

  scope :ordered, -> { order(logged_at: :desc) }

  def self.parse_duration(str)
    return nil if str.blank?
    s = str.to_s.strip.downcase.gsub(",", ".")
    total = 0.0
    total += Regexp.last_match(1).to_f * 60 if s =~ /(\d+(?:\.\d+)?)\s*h/
    total += Regexp.last_match(1).to_f      if s =~ /(\d+(?:\.\d+)?)\s*m/
    # bare number → minutes
    total = s.to_f if total.zero? && s =~ /\A\d+(?:\.\d+)?\z/
    total.round.positive? ? total.round : nil
  end

  def formatted
    h, m = minutes.divmod(60)
    return "#{h}h #{m}m" if h > 0 && m > 0
    return "#{h}h"       if h > 0
    "#{m}m"
  end
end
