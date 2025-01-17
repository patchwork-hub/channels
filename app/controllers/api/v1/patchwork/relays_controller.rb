# frozen_string_literal: true

class Api::V1::Patchwork::RelaysController < Api::BaseController
  before_action :require_user!
  before_action :check_owner!
  before_action :set_relay, except: [:create]

  def create
    @relay = Relay.find_or_initialize_by(relay_params)
    unless @relay.persisted?
      @relay.save
      @relay.enable!
    end

    head 200
  end

  def destroy
    @relay.destroy
    render_empty
  end

  private

  def check_owner!
    render json: { error: 'Forbidden' }, status: 403 unless current_user.role.name == 'Owner'
  end

  def set_relay
    @relay = Relay.find(params[:id])
  end

  def relay_params
    params.permit(:inbox_url)
  end
end
