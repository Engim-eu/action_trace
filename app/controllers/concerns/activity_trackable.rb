# frozen_string_literal: true

module ActivityTrackable
  extend ActiveSupport::Concern

  included do
    include PublicActivity::StoreController

    after_action :track_action
  end

  private

  def track_action
    return if should_skip_tracking?

    properties = {
      path: request.path,
      method: request.method,
      controller: controller_name,
      action: action_name,
      company_id: current_company_id
    }

    ahoy.track ActionTrace::ActivityLog::SOURCES[:page_visit], properties
  end

  def track_session_end
    ahoy.track ActionTrace::ActivityLog::SOURCES[:session_end],
               reason: 'logout',
               ip: request.remote_ip,
               user_agent: request.user_agent,
               visit_id: ahoy.visit&.id
    ahoy.reset_visit
  end

  def current_company_id
    current_user&.company_id
  end

  def should_skip_tracking?
    !response.successful? ||
      ActionTrace.configuration.excluded_controllers.include?(controller_name) ||
      ActionTrace.configuration.excluded_actions.include?(action_name) ||
      current_user.nil?
  end
end
