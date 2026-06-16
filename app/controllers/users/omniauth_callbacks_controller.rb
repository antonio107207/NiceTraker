class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth("Google")
  end

  def github
    handle_auth("GitHub")
  end

  def gitlab
    handle_auth("GitLab")
  end

  def failure
    redirect_to root_path, alert: "Authentication failed: #{failure_message}"
  end

  private

  def handle_auth(provider_name)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
  rescue => e
    Rails.logger.error "OmniAuth #{provider_name} error: #{e.message}"
    redirect_to new_user_session_path, alert: "Could not authenticate with #{provider_name}."
  end
end
