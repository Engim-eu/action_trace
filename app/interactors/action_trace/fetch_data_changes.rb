# frozen_string_literal: true

module ActionTrace
  class FetchDataChanges
    include Interactor
    include ActivityLogFetchable

    def call
      return unless should_fetch?('data_change')

      scope = base_scope(PublicActivity::Activity)
      context.total_count += scope.count

      entries = scope.includes(:owner, :trackable)
                     .order(created_at: :desc)
                     .offset(context.range).limit(context.per_page)
                     .map do |activity|
        {
          id: "act_#{activity.id}",
          source: source_type(activity),
          occurred_at: activity.created_at,
          user: activity.owner&.complete_name,
          trackable_type: activity.trackable_type,
          details: activity.parameters || {},
          paper_trail_version: PaperTrail::Version.find_by(id: activity.version_id),
          trackable: activity.trackable
        }
      end

      context.raw_collection += entries
    end

    private

    def source_type(activity)
      if activity.key.to_s.include?('destroy')
        ActionTrace::ActivityLog::SOURCES[:data_destroy]
      elsif activity.key.to_s.include?('create')
        ActionTrace::ActivityLog::SOURCES[:data_create]
      else
        ActionTrace::ActivityLog::SOURCES[:data_change]
      end
    end
  end
end
