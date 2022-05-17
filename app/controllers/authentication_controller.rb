class AuthenticationController < ApplicationController
    before_action :authorize_request, except: :login

    # POST /auth/login
    def login
        @user = User.find_by_username!(params[:username])
        if @user&.authenticate(params[:password])
            payload = {user_id: @user.id, username: @user.username}
            token = JsonWebToken.encode(payload)
            time = Time.now + 24.hours.to_i
            render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                        username: @user.username ,
                        id: @user.id}, status: :ok
        else
            render json: { error: 'unauthorized' }, status: :unauthorized
        end
    end
  
    private
  
    def login_params
        params.permit(:username, :password)
    end
end
