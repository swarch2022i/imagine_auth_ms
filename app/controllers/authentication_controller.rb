class AuthenticationController < ApplicationController
    before_action :authorize_request, except: :login

    # POST /auth/login
    def login
        @user = User.find_by_username!(params[:username])
        if @user&.authenticate(params[:password])
            ldap = Net::LDAP.new(:host => ENV['LDAP_HOST'], :port => 389)
            if ldap.bind(:method => :simple, :username => "cn=#{params[:username]},ou=auth,dc=imagine,dc=unal,dc=edu,dc=co",
                :password => params[:password])

                payload = {user_id: @user.id, username: @user.username}
                token = JsonWebToken.encode(payload)
                time = Time.now + 24.hours.to_i
                render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                            username: @user.username ,
                            id: @user.id}, status: :ok
            else
                render json: { error: "#{ldap.get_operation_result}" }, status: :unauthorized
            end
        else
            render json: { error: 'unauthorized' }, status: :unauthorized
        end
    end
  
    private
  
    def login_params
        params.permit(:username, :password)
    end
end
