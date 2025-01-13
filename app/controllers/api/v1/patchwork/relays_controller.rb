# frozen_string_literal: true

class Api::V1::Patchwork::RelaysController < Api::BaseController
  before_action :require_user!
  before_action :set_relay, except: [:create]

  def create
    authorize :relay, :update?

    @relay = Relay.find_or_initialize_by(relay_params)
    unless @relay.persisted?
      @relay.save
      @relay.enable!
    end

    head 200
  end

  def destroy
    authorize :relay, :update?
    @relay.destroy
    render_empty
  end

  private

  def set_relay
    @relay = Relay.find(params[:id])
  end

  def relay_params
    params.require(:relay).permit(:inbox_url)
  end
end
