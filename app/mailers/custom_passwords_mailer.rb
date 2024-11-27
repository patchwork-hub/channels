# frozen_string_literal: true

class CustomPasswordsMailer < ApplicationMailer
  layout 'email'
  default from: %{Newsmast <#{ENV['SMTP_FROM_ADDRESS']}>}

  def reset_password_confirmation
    @user = params[:user]
    @web = params[:web]
    if @user.present?
      @subject = 'Reset your password'
      mail(to: @user.email, subject: @subject)
    end
  end
end
