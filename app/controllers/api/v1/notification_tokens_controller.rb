# frozen_string_literal: true

class Api::V1::NotificationTokensController < Api::BaseController
  before_action :require_user!
  before_action -> { doorkeeper_authorize! :read, :write }
  before_action :set_notification_token, only: [:create, :revoke_notification_token]
  before_action :set_platform_tokens, only: [:reset_device_tokens]
  before_action :fetch_notification_tokens, only: [:update_mute, :get_mute_status]

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

  def get_mute_status
    if @notification_tokens.present?
      render json: { mute: @notification_tokens.first.mute }
    else
      render json: { message: 'No notification tokens found' }, status: 404
    end
  end

  def update_mute
    if @notification_tokens.present?
      @notification_tokens.update_all(mute: params[:mute])
      render json: { message: 'Mute status updated successfully' }
    else
      render json: { message: 'No notification tokens found' }, status: 404
    end
  end

  def reset_device_tokens
    if @notification_tokens.present?
      @notification_tokens.destroy_all
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
    params.permit(:notification_token, :platform_type, :mute)
  end

  def fetch_notification_tokens
    @notification_tokens = NotificationToken.where( account_id: current_account.id)
  end

  def set_platform_tokens
    @notification_tokens = NotificationToken.where(platform_type: params[:platform_type], account_id: current_account.id)
  end
end
