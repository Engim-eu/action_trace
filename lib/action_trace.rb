# frozen_string_literal: true

require 'action_trace/version'
require 'action_trace/configuration'
require 'action_trace/engine'

module ActionTrace
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
