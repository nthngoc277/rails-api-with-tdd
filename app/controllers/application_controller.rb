class ApplicationController < ActionController::API
  rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error

  private 
  def authentication_error
    errors = {  "status": "401",
      "source": { "pointer": "/code" },
      "title":  "Authentication code is invalid",
      "detail": "You mush provide valid code in order to exchange it for token"
    }
    render json: {'errors': [errors]}, status: 401
  end
end
