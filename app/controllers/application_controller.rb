class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end

  rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error
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

  def authentication_error
    errors = {  "status": "401",
      "source": { "pointer": "/code" },
      "title":  "Authentication code is invalid",
      "detail": "You mush provide valid code in order to exchange it for token"
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
