# frozen_string_literal: true

module ActionTrace
  class FetchPageVisits
    include Interactor
    include ActivityLogFetchable

    def call
      return unless should_fetch_any?(%w[page_visit session_end])

      scope = base_scope(Ahoy::Event)
      scope = apply_source_filter(scope)

      context.total_count += scope.count
      context.raw_collection += map_entries(scope)
    end

    private

    def should_fetch_any?(sources)
      sources.any? { |s| should_fetch?(s) }
    end

    def apply_source_filter(scope)
      case context.source
      when ActionTrace::ActivityLog::SOURCES[:session_end] then scope.where(name: ActionTrace::ActivityLog::SOURCES[:session_end])
      when ActionTrace::ActivityLog::SOURCES[:page_visit] then scope.where(name: ActionTrace::ActivityLog::SOURCES[:page_visit])
      else scope
      end
    end

    def map_entries(scope)
      scope.includes(:user)
           .order(time: :desc)
           .offset(context.range).limit(context.per_page)
           .map { |event| format_entry(event) }
    end

    def format_entry(event)
      props = event.properties || {}
      {
        id: "ahoy_#{event.id}",
        source: event.name == 'session_end' ? 'session_end' : 'page_visit',
        occurred_at: event.time,
        user: event.user&.complete_name,
        url: props['path'],
        details: props
      }
    end
  end
end
