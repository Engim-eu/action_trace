# frozen_string_literal: true

module ActionTrace
  class ActivityLog
    extend ActiveModel::Translation
    include ActionTrace::ActivityLogPresenter

    attr_reader :id, :source, :occurred_at, :user, :raw_subject, :details, :url, :paper_trail_version, :trackable,
                :trackable_type

    SOURCES = {
      data_create: 'data_create',
      data_change: 'data_change',
      data_destroy: 'data_destroy',
      page_visit: 'page_visit',
      session_start: 'session_start',
      session_end: 'session_end'
    }.freeze

    def initialize(attributes = {})
      @id = attributes[:id]
      @source = attributes[:source]
      @occurred_at = attributes[:occurred_at]
      @user = attributes[:user]
      @raw_subject = attributes[:subject]
      @details = attributes[:details] || {}
      @url = attributes[:url]
      @paper_trail_version = attributes[:paper_trail_version]
      @trackable = attributes[:trackable]
      @trackable_type = attributes[:trackable_type]
    end

    def data_create?
      source == SOURCES[:data_create]
    end

    def data_change?
      source == SOURCES[:data_change]
    end

    def data_destroy?
      source == SOURCES[:data_destroy]
    end

    def page_visit?
      source == SOURCES[:page_visit]
    end

    def session_start?
      source == SOURCES[:session_start]
    end

    def human_trackable_type
      return nil if trackable_type.blank?

      trackable_type.constantize.model_name.human
    rescue StandardError
      trackable_type
    end
  end
end
