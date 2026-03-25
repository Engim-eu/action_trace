# frozen_string_literal: true

module ActionTrace
  module ActivityLogPresenter
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::TagHelper

    VISUAL_CONFIG = {
      'data_create' => { icon: 'fas fa-plus-circle', color: 'text-success' },
      'data_change' => { icon: 'fas fa-pencil-alt', color: 'text-primary' },
      'data_destroy' => { icon: 'fas fa-trash-alt', color: 'text-danger' },
      'page_visit' => { icon: 'fas fa-globe-pointer', color: 'text-secondary' },
      'session_start' => { icon: 'fas fa-arrow-left-to-bracket', color: 'text-warning' },
      'session_end' => { icon: 'fas fa-arrow-right-to-bracket', color: 'text-danger' }
    }.freeze

    def icon
      visual[:icon]
    end

    def color
      visual[:color]
    end

    def subject
      return raw_subject unless %w[page_visit session_end].include?(source)

      format_subject(details['controller'], details['action'], details['path'])
    end

    private

    def visual
      VISUAL_CONFIG[source] || VISUAL_CONFIG['page_visit']
    end

    def format_subject(controller, action, path)
      return path if controller.blank?

      singular, plural = model_names_for(controller)

      case action
      when 'index'
        "#{I18n.t('.list')} #{plural}"
      when 'show'
        "#{I18n.t('.details')} #{singular}"
      when 'new', 'create', 'edit', 'update', 'destroy', 'delete'
        "#{I18n.t(".#{action_key(action)}")} #{singular}"
      else
        path
      end
    end

    def model_names_for(controller)
      model_class = controller.classify.constantize
      [model_class.model_name.human, model_class.model_name.human(count: 2)]
    rescue NameError
      [controller.humanize.singularize, controller.humanize]
    end

    def action_key(action)
      case action
      when 'new', 'create' then 'new'
      when 'edit', 'update' then 'edit'
      when 'destroy', 'delete' then 'destroy'
      else 'show'
      end
    end
  end
end
