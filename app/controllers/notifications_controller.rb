class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_read!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("notification_#{notification.id}",
            partial: "notifications/notification",
            locals: { notification: notification }),
          turbo_stream.replace("notification_badge",
            partial: "notifications/badge",
            locals: { count: current_user.notifications.unread.count })
        ]
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
            locals: { notifications: current_user.notifications.recent.includes(:actor, :notifiable) })
        ]
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
