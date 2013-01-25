module EducakeAPI::Helpers
  module Authentication
    def warden
      env['warden']
    end

    def authenticate_user
      if current_user
        return true
      else
        error!('401 Unauthorized', 401)
      end
    end

    def current_user
      return token.user if token
    end

    def oauth20_token
      if env["oauth.version"]==2
        env["oauth.token"]
      end
    end

    def oauth10_token
      if env["oauth.version"]==1
        env["oauth.token"]
      end
    end

    def oauth10_access_token
      oauth10_token && oauth10_token.is_a?(::AccessToken) ? oauth10_token : nil
    end

    def token
      oauth20_token || oauth10_access_token || nil
    end

    def client_application
      env["oauth.version"]==1 && env["oauth.client_application"] || oauth20_token.try(:client_application)
    end

    def two_legged
      env["oauth.version"]==1 && client_application
    end
  end
end
