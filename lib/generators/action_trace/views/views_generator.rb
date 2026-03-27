# frozen_string_literal: true

require 'rails/generators'

module ActionTrace
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      desc 'Copy ActionTrace views to your application for customization'

      class_option :controller, type: :boolean, default: false,
                                desc: 'Also copy the ActivityLogsController to your application'

      def self.source_root
        File.expand_path('templates', __dir__)
      end

      def copy_views
        directory 'views/action_trace', 'app/views/action_trace'
      end

      def copy_controller
        return unless options[:controller]

        copy_file(
          File.expand_path('../../../../app/controllers/action_trace/activity_logs_controller.rb', __dir__),
          'app/controllers/action_trace/activity_logs_controller.rb'
        )
      end
    end
  end
end
