# frozen_string_literal: true

module ActionTrace
  class MergeAndFormatResults
    include ::Interactor
    include ActivityLogFetchable

    def call
      sorted_results = context.raw_collection
                              .sort_by { |item| item[:occurred_at] }
                              .reverse
                              .first(context.per_page)

      context.activity_logs = sorted_results.map { |attrs| ActionTrace::ActivityLog.new(attrs) }

      total = context.total_count
      context.activity_logs.define_singleton_method(:total_count) { total }
    end
  end
end
