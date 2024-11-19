# frozen_string_literal: true

class Api::V1::CustomLoginsController < Api::BaseController
  skip_before_action :require_authenticated_user!

  def index
    if params[:email].present?
      user = User.find_by(email: params[:email])
      user.reset_password!
      #CustomMailer.with(user: user).reset_password_confirmation.deliver_now
    end
  end
end
