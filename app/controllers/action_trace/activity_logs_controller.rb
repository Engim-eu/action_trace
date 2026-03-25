# frozen_string_literal: true

module ActionTrace
  class ActivityLogsController < ApplicationController
    # Uncomment and adapt to your authentication/authorization setup.
    # Run `rails generate action_trace:views --controller` to copy this file into your app.
    #
    # before_action :authenticate_user!   # Devise
    # load_and_authorize_resource          # CanCanCan

    def index
      @filters = session[:activity_logs_filters] || {}

      result = ActionTrace::FetchActivityLogs.call(
        filters: @filters,
        current_user: current_user,
        range: params[:range] || 0
      )

      if result.success?
        @activity_logs = result.activity_logs
        @activity_logs_count = result.total_count
      else
        flash.now[:error] = result.message
        @activity_logs = []
        @activity_logs_count = 0
      end

      return unless request.xhr?

      response.headers['Cache-Control'] = 'no-store'
      render partial: 'index'
    end

    def filter
      session[:activity_logs_filters] = if params[:reset].present?
                                          {}
                                        else
                                          params[:filters]
                                        end
      redirect_to activity_logs_path
    end
  end
end
