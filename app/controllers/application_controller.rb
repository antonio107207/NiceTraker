class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes
  before_action :set_locale
  before_action :authenticate_user!
  before_action :use_html_for_get_turbo_stream
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_locale
    requested = session[:locale]&.to_sym
    I18n.locale = I18n.available_locales.include?(requested) ? requested : I18n.default_locale
  end

  def user_not_authorized
    flash[:alert] = t("flash.not_authorized")
    redirect_back_or_to root_path
  end

  # Turbo adds text/vnd.turbo-stream.html to Accept on pages with turbo_stream_from.
  # GET requests should always render HTML — only POST/PATCH/DELETE use streams.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])
  end

  def use_html_for_get_turbo_stream
    request.format = :html if request.get? && request.format.to_sym == :turbo_stream
  end
end
