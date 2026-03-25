# frozen_string_literal: true

module ActionTrace
  module DataTrackable
    extend ActiveSupport::Concern

    included do
      include PublicActivity::Common

      after_commit :track_create_activity, on: :create
      after_commit :track_update_activity, on: :update
      before_destroy :track_destroy_activity
    end

    private

    def track_create_activity
      track_activity('create')
    end

    def track_update_activity
      track_activity('update')
    end

    def track_destroy_activity
      track_activity('destroy')
    end

    def devise_actions?
      controller = PublicActivity.get_controller
      return false if controller.nil?
      return false unless defined?(DeviseController)

      controller.is_a?(DeviseController) || controller.is_a?(Devise::SessionsController)
    end

    def track_activity(action)
      return if devise_actions?

      current_user = PublicActivity.get_controller&.current_user

      create_activity(
        key: action_key(action),
        owner: current_user,
        version_id: action_version_id,
        params: action_params
      )
    end

    def action_key(action)
      "#{self.class.name.downcase}.#{action}"
    end

    def action_version_id
      return nil unless respond_to?(:versions)

      versions.reload.last&.id
    end

    def action_params
      { id: id, display_name: try(:name) || try(:complete_name) || id }
    end
  end
end
