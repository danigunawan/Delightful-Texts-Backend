class ApplicationController < ActionController::API
  before_action :authorized
  # protect_from_forgery with: :exception

  def encode_token(payload)
    # payload => { beef: 'steak' }
    # should store secret in env variable 
    JWT.encode(payload, secret)
    # jwt string: "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI" 
  end

  def auth_header
    # { 'Authorization': 'Bearer <token>' }
    request.headers['Authorization']
  end

  def secret
    #ENV['delightful_texts_jwt_secret']
    "badbreathbuffalo"
  end

  def decoded_token
    # token => "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
    if auth_header
      token = auth_header.split(' ')[1]
      # headers: { 'Authorization': 'Bearer <token>' }
      begin
        JWT.decode(token, secret)[0]
        # JWT.decode => [{ "beef"=>"steak" }, { "alg"=>"HS256" }]
        # [0] gives us the payload { "beef"=>"steak" }
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decoded_token
      # decoded_token=> [{"user_id"=>2}, {"alg"=>"HS256"}]
      # or nil if we can't decode the token
     
      # user_id = decoded_token[0]['user_id']
      user_id = decoded_token['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: { message: "You have to log in first!" }, status: :unauthorized unless logged_in?
  end

end
