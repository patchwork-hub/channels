# frozen_string_literal: true

class CustomPasswordsController < ApplicationController
  skip_before_action :require_functional!

  def edit
    @user = User.find_by(reset_password_token: params[:reset_password_token])
  end

  def update
    @user = User.find_by(reset_password_token: params[:reset_password_token])
    if params[:user][:password].present?
      @user.password = params[:user][:password]
      @user.save(validate: false)
      render json: { message: 'Password update successfully.' }
    else
      render json: { message: 'Password unmatch.' }, status: 422
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { message: 'Password update unsuccessfully.' }, status: 422
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
