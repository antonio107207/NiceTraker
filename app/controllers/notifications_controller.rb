class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_read!
    respond_to do |format|
      format.turbo_stream do
        remaining = current_user.notifications.unread.count
        render turbo_stream: [
          turbo_stream.remove("notification_#{notification.id}"),
          turbo_stream.replace("notification_badge",
            partial: "notifications/badge",
            locals: { count: remaining }),
          (turbo_stream.replace("notifications_list",
            partial: "notifications/list",
            locals: { notifications: [] }) if remaining.zero?)
        ].compact
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("notification_badge",
            partial: "notifications/badge",
            locals: { count: 0 }),
          turbo_stream.replace("notifications_list",
            partial: "notifications/list",
            locals: { notifications: [] })
        ]
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
