module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      # POST /api/v1/auth/facebook
      def facebook
        user_params = FacebookService.new(params[:access_token]).profile
        if user_params && user_params['id'] == params[:uid]
          @resource = User.from_provider('facebook', user_params)
          sign_in(:user, @resource)
          new_auth_header = @resource.create_new_auth_token
          response.headers.merge!(new_auth_header)
          render_create_success
        else
          render(
            json: { error: I18n.t('api.sessions.facebook.forbidden') },
            status: :forbidden
          )
        end
      rescue Koala::Facebook::AuthenticationError
        render(
          json: { error: I18n.t('api.sessions.facebook.forbidden') },
          status: :forbidden
        )
      rescue ActiveRecord::RecordNotUnique
        render(
          json: { error: I18n.t('api.sessions.facebook.already_registered') },
          status: :bad_request
        )
      end
    end
  end
end
