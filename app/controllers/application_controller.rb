class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end

  rescue_from UserAuthenticator::Oauth::AuthenticationError, with: :authentication_oauth_error
  rescue_from UserAuthenticator::Standard::AuthenticationError, with: :authentication_standard_error
  rescue_from AuthorizationError, with: :forbidden_request_error

  before_action :authorize!

  private 

  def access_token
    provided_token = request.authorization&.gsub(/\ABearer\s/, '')
    @access_token = AccessToken.find_by_token(provided_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  def authorize!
    raise AuthorizationError unless current_user
  end

  def authentication_oauth_error
    errors = {  "status": "401",
      "source": { "pointer": "/code" },
      "title":  "Authentication code is invalid",
      "detail": "You must provide valid code in order to exchange it for token"
    }
    render json: {'errors': [errors]}, status: 401
  end

  def authentication_standard_error
    errors = { "status"=>"401",
      "source"=>{ "pointer"=>"/data/attributes/password" },
      "title"=> "Invalid login or password",
      "detail"=>"You must provide valid credentials in order to exchange them for token"
    }
    render json: {'errors': [errors]}, status: 401
  end

  def forbidden_request_error
    errors = {
      'status' => '403',
      'source' => { 'pointer' => 'header/authorization' },
      'title' => 'Not authorized',
      'detail' => 'You have no right to access this resource'
    }
    render json: {'errors': [errors]}, status: 403
  end
end
