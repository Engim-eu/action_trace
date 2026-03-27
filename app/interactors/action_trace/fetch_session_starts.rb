# frozen_string_literal: true

module ActionTrace
  class FetchSessionStarts
    include ::Interactor
    include ActivityLogFetchable

    def call
      return unless should_fetch?('session_start')

      scope = base_scope(Ahoy::Visit)
      context.total_count += scope.count

      entries = scope.includes(:user)
                     .order(started_at: :desc)
                     .offset(context.range).limit(context.per_page)
                     .map do |visit|
        {
          id: "visit_#{visit.id}",
          source: 'session_start',
          occurred_at: visit.started_at,
          user: visit.user&.complete_name,
          subject: "#{visit.browser} on #{visit.os} (#{visit.ip})",
          details: visit.attributes.slice('ip', 'browser', 'os', 'device_type', 'country', 'landing_page', 'user_agent')
        }
      end

      context.raw_collection += entries
    end
  end
end
