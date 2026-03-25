# frozen_string_literal: true

module ActionTrace
  class PurgeActivityLogJob < ApplicationJob
    queue_as :maintenance

    def perform
      threshold = ActionTrace.configuration.log_retention_period.ago

      act_count = PublicActivity::Activity.where('created_at < ?', threshold).delete_all
      evt_count = Ahoy::Event.where('time < ?', threshold).delete_all
      vst_count = Ahoy::Visit.where('started_at < ?', threshold).delete_all

      Rails.logger.info "Activity log: Removed #{act_count} PublicActivities, #{evt_count} AhoyEvents, #{vst_count} AhoyVisits."
    end
  end
end
