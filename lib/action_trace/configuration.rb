# frozen_string_literal: true

module ActionTrace
  class Configuration
    attr_accessor :excluded_actions, :excluded_controllers, :user_class, :log_retention_period

    def initialize
      @excluded_actions      = []
      @excluded_controllers  = []
      @user_class            = 'User'
      @log_retention_period  = 1.year
    end
  end
end
