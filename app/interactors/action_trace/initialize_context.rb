# frozen_string_literal: true

module ActionTrace
  class InitializeContext
    include ::Interactor

    def call
      filters = context.filters || {}
      user = context.current_user

      context.company_id = filters['company_id'].presence || user.company_id
      context.user_id = filters['user_id']
      context.source = filters['source']
      context.start_date = filters['start_date']
      context.end_date = filters['end_date']
      context.range = context.range.to_i
      context.per_page = 50

      context.raw_collection = []
      context.total_count = 0
    end
  end
end
