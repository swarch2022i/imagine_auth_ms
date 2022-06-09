class UsersController < ApplicationController
    before_action :authorize_request, except: :create
    before_action :find_user, except: %i[create index]

    # GET /users
    def index
        @users = User.all
        render json: @users, status: :ok
    end

    # GET /users/{username}
    def show
        render json: @user, status: :ok
    end

    # POST /users
    def create
        @user = User.new(user_params)
        if @user.save
            dn = "cn=#{params[:username]},ou=auth,dc=imagine,dc=unal,dc=edu,dc=co"
            cryptPassword = params[:password]
            attr = {
                :cn => params[:username],
                :sn => params[:username],
                :uid => params[:username],
                :objectclass => ["inetOrgPerson", "top", "posixAccount"],
                :gidNumber => "500",
                :uidNumber => "#{1000 + @user.id}",
                :userPassword => cryptPassword,
                :homeDirectory => "/home/users/#{params[:username]}"
            }
            ldap = Net::LDAP.new :host => ENV['LDAP_HOST'],
                :port => 389,
                :auth => {
                    :method => :simple,
                    :username => "cn=admin,dc=imagine,dc=unal,dc=edu,dc=co",
                    :password => "admin"
            }
            ldap.add(:dn => dn, :attributes => attr)
            render json: @user, status: :created
        else
            render json: { errors: @user.errors.full_messages },
                    status: :unprocessable_entity
        end
    end

    # PUT /users/{username}
    def update
        if @user&.authenticate(params[:actual_password])
            if @user.update(user_params)
                render json: @user, status: :created
            else
                render json: { errors: @user.errors.full_messages },
                        status: :unprocessable_entity
            end
        else
            render json: { error: 'wrong password' }, status: :unauthorized
        end
    end

    # DELETE /users/{username}
    def destroy
        @user.destroy
    end

    private

    def find_user
        @user = User.find_by_id!(params[:_id])
        rescue ActiveRecord::RecordNotFound
        render json: { errors: 'User not found' }, status: :not_found
    end

    def user_params
        params.permit(
            :username, :password, :password_confirmation
        )
    end
end
