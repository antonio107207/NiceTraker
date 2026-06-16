class LocalesController < ApplicationController
  skip_before_action :authenticate_user!

  def update
    locale = params[:locale].to_sym
    session[:locale] = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
    redirect_back_or_to root_path
  end
end
