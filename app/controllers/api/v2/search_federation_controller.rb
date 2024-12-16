# frozen_string_literal: true

class Api::V2::SearchFederationController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = 20

  before_action -> { authorize_if_got_token! :read, :'read:search' }
  before_action :require_user!

  before_action :validate_search_params!

  def index
    @search = search_results
    render json: @search
  rescue Mastodon::SyntaxError
    unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private

  def validate_search_params!
    return if user_signed_in?

    return render json: { error: 'Search queries pagination is not supported without authentication' }, status: 401 if params[:offset].present?

    render json: { error: 'Search queries that resolve remote resources are not supported without authentication' }, status: 401 if truthy_param?(:resolve)
  end

  def search_results
    Patchwork::Federation::SearchService.new.call(
      params[:url],
      current_account,
      limit_param(RESULTS_LIMIT),
      doorkeeper_token: doorkeeper_token
    )
  end

  def search_params
    params.permit(:type, :url, :offset, :min_id, :max_id)
  end
end
