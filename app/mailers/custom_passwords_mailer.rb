# frozen_string_literal: true

class CustomPasswordsMailer < ApplicationMailer
  layout 'email'
  default from: %{Channel <#{ENV['SMTP_FROM_ADDRESS']}>}

  def reset_password_confirmation
    @user = params[:user]
    if @user.present?
      @subject = 'OTP verification code'
      mail(to: @user.email, subject: @subject)
    end
  end
end
