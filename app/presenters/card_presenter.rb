class CardPresenter < SimpleDelegator
  def status_label
    return "Archived"  if archived_at?
    return "Completed" if due_completed?
    return "Overdue"   if overdue?
    "Active"
  end

  def overdue?
    due_date.present? && due_date < Time.current && !due_completed?
  end

  def due_soon?
    due_date.present? && due_date <= 2.days.from_now && !due_completed? && !overdue?
  end

  def checklist_summary
    done, total = checklist_progress
    total > 0 ? "#{done}/#{total}" : nil
  end

  def time_logged_formatted
    min = total_logged_minutes
    return nil if min.zero?
    h, m = min.divmod(60)
    return "#{h}h #{m}m" if h > 0 && m > 0
    return "#{h}h"       if h > 0
    "#{m}m"
  end
end
