# frozen_string_literal: true

class Api::V1::NotificationTokensController < Api::BaseController
  before_action :require_user!
  before_action -> { doorkeeper_authorize! :read , :write}
  before_action :set_notification_token, only: %i[create]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def create
    unless @notification_token.present?
      NotificationToken.create!(notification_token_params.merge(account_id: current_account.id))
      render json: {message: "notification token saved"}
    else
      render json: {message: "notification token already exists"}
    end
  end

  private

  def set_notification_token
    @notification_token = NotificationToken.find_by(notification_token: params[:notification_token],account_id: current_account.id)
  end

  def notification_token_params
    params.permit(:notification_token, :platform_type)
  end

end
