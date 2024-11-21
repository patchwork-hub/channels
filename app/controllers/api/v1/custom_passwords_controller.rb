# frozen_string_literal: true

class Api::V1::CustomPasswordsController < Api::BaseController
  skip_before_action :require_authenticated_user!

  layout 'email'
  def index
    user = User.find_by(email: params[:email])
    if user
      user.reset_password!
      CustomPasswordsMailer.with(user: user).reset_password_confirmation.deliver_later
    else
      render json: { error: 'Email not found!' }, status: 404
    end
  end
end
