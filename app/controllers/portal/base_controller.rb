class Portal::BaseController < ApplicationController
  layout "portal"
  before_action :require_super_admin!

  private

  def require_super_admin!
    redirect_to root_path, alert: t("portal.not_authorized") unless current_user&.super_admin?
  end
end
