# frozen_string_literal: true

class Api::V1::NotificationTokensController < Api::BaseController
  before_action :require_user!
  before_action -> { doorkeeper_authorize! :read, :write }
  before_action :set_notification_token, only: [:create, :revoke_notification_token]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def create
    if @notification_token.present?
      render json: { message: 'Notification token already exists' }
    else
      NotificationToken.create!(notification_token_params.merge(account_id: current_account.id))
      render json: { message: 'Notification token saved' }
    end
  end

  def revoke_notification_token
    if @notification_token.present?
      @notification_token.destroy!
      render json: { message: 'Notification token deleted successfully' }
    else
      render json: { message: 'Record not found' }, status: 404
    end
  end

  private

  def set_notification_token
    @notification_token = NotificationToken.find_by(notification_token: params[:notification_token], account_id: current_account.id)
  end

  def notification_token_params
    params.permit(:notification_token, :platform_type)
  end
end
