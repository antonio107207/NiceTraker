OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.silence_get_warning = true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV.fetch("GOOGLE_CLIENT_ID", ""),
           ENV.fetch("GOOGLE_CLIENT_SECRET", ""),
           scope: "email,profile"

  provider :github,
           ENV.fetch("GITHUB_CLIENT_ID", ""),
           ENV.fetch("GITHUB_CLIENT_SECRET", ""),
           scope: "user:email"

  provider :gitlab,
           ENV.fetch("GITLAB_APP_ID", ""),
           ENV.fetch("GITLAB_APP_SECRET", ""),
           scope: "read_user",
           site: ENV.fetch("GITLAB_URL", "https://gitlab.com")
end
