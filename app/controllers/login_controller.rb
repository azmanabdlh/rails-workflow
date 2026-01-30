class LoginController < ApplicationController
  allow_unauthenticated_access only: %i[ call ]

  def call
    if user = User.authenticate_by(params.permit(:email, :password))
      token = start_new_token_for(user)
      render json: { message: "signed in", token: token }
    else
      render json: { message: "try another email address or password." }
    end
  end
end
