# frozen_string_literal: true

module ActivityLogFetchable
  extend ActiveSupport::Concern

  def should_fetch?(source_type)
    return true if context.source.blank?

    if %w[data_change data_destroy].include?(source_type)
      return context.source == ActionTrace::ActivityLog::SOURCES[:data_change] ||
             context.source == ActionTrace::ActivityLog::SOURCES[:data_destroy] ||
             context.source == ActionTrace::ActivityLog::SOURCES[:data_create]
    end

    context.source == source_type
  end

  def base_scope(model_class)
    scope = model_class.all
    scope = apply_activity_type_filter(scope) if model_class == PublicActivity::Activity
    if context.company_id.present?
      scope = if model_class.respond_to?(:filter_by_company)
                model_class.filter_by_company(scope, context.company_id)
              else
                scope.where(company_id: context.company_id)
              end
    end

    user_column = model_class == PublicActivity::Activity ? :owner_id : :user_id
    scope = scope.where(user_column => context.user_id) if context.user_id.present?

    apply_date_filters(scope, model_class)
  end

  private

  def apply_activity_type_filter(scope)
    return scope if context.source.blank?

    case context.source
    when ActionTrace::ActivityLog::SOURCES[:data_destroy]
      scope.where('activities.`key` LIKE ?', '%.destroy')
    when ActionTrace::ActivityLog::SOURCES[:data_change]
      scope.where('activities.`key` LIKE ?', '%.update')
    when ActionTrace::ActivityLog::SOURCES[:data_create]
      scope.where('activities.`key` LIKE ?', '%.create')
    else
      scope
    end
  end

  def apply_date_filters(scope, model_class)
    date_column = date_column_for(model_class)
    table = model_class.table_name

    scope = apply_start_date_filter(scope, table, date_column)
    apply_end_date_filter(scope, table, date_column)
  rescue ArgumentError
    scope
  end

  def date_column_for(model_class)
    case model_class.to_s
    when 'Ahoy::Event' then :time
    when 'Ahoy::Visit' then :started_at
    else :created_at
    end
  end

  def apply_start_date_filter(scope, table, column)
    return scope if context.start_date.blank?

    scope.where(table => { column => Date.parse(context.start_date).beginning_of_day.. })
  end

  def apply_end_date_filter(scope, table, column)
    return scope if context.end_date.blank?

    scope.where(table => { column => ..Date.parse(context.end_date).end_of_day })
  end
end
