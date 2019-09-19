class Api::V1::UsersController < ApplicationController
  skip_before_action :authorized, only: [:create]

  def profile
    # If you want to use Serializer
    # render json: { user: UserSerializer.new(current_user) }, status: :accepted
    render json: { user: current_user }, status: :accepted
  end

  def index
    @users = User.all
    render json: { users: @users }
  end

  def create
    @user = User.create(user_params)
   
    if @user.valid?

      @token = encode_token(user_id: @user.id)
      
      # If you want to use serializer
      # render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
      render json: { user: @user, jwt: @token }, status: :created
    else
      render json: { error: 'Failed to create user' }, status: :not_acceptable
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end

end
