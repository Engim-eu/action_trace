# frozen_string_literal: true

require 'rails/generators'

module ActionTrace
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def self.source_paths
        [File.expand_path('templates', __dir__), File.expand_path(__dir__)]
      end

      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end
      desc 'Install ActionTrace and all its dependencies'

      class_option :skip_ahoy,            type: :boolean, default: false,
                                          desc: 'Skip ahoy_matey generator (already installed)'
      class_option :skip_paper_trail,     type: :boolean, default: false,
                                          desc: 'Skip paper_trail generator (already installed)'
      class_option :skip_public_activity, type: :boolean, default: false,
                                          desc: 'Skip public_activity generator (already installed)'
      class_option :skip_discard,         type: :boolean, default: false,
                                          desc: 'Skip discard generator (already installed)'

      def run_ahoy_install
        unless options[:skip_ahoy]
          generate 'ahoy:install'
          patch_ahoy_initializer
        end
        inject_ahoy_filter_by_company
      end

      def run_paper_trail_install
        generate 'paper_trail:install' unless options[:skip_paper_trail]
      end

      def run_public_activity_migration
        generate 'public_activity:migration' unless options[:skip_public_activity]
      end

      def create_add_version_id_migration
        migration_template(
          'migrations/add_version_id_to_activities.rb.tt',
          'db/migrate/add_version_id_to_activities.rb'
        )
      end

      def create_initializer
        template 'initializers/action_trace.rb.tt', 'config/initializers/action_trace.rb'
      end

      def pin_ahoy_for_importmap
        return if options[:skip_ahoy]
        return unless File.exist?('config/importmap.rb')

        append_to_file 'config/importmap.rb', %(pin "ahoy", to: "ahoy.js"\n)
      end

      def import_ahoy_in_javascript
        return if options[:skip_ahoy]
        return unless File.exist?('app/javascript/application.js')

        append_to_file 'app/javascript/application.js', %(import "ahoy"\n)
      end

      def create_javascript_tracking_file
        return if options[:skip_ahoy]
        return unless File.exist?('app/javascript')

        template 'action_trace.js.tt', 'app/javascript/action_trace.js'
        append_to_file 'app/javascript/application.js', %(import "./action_trace"\n) if File.exist?('app/javascript/application.js')
      end

      private

      def patch_ahoy_initializer
        gsub_file 'config/initializers/ahoy.rb', 'Ahoy.api = false', 'Ahoy.api = true'
        append_to_file 'config/initializers/ahoy.rb', "\nAhoy.server_side_visits = false\n"
      end

      def inject_ahoy_filter_by_company
        filter_method = <<~RUBY

          def self.filter_by_company(scope, company_id)
            scope.joins(:user).where(users: { company_id: company_id })
          end
        RUBY

        %w[visit event].each do |model|
          inject_into_file "app/models/ahoy/#{model}.rb", filter_method, before: "  end\nend\n"
        end
      end

      public

      def show_post_install_message
        readme 'POST_INSTALL' if behavior == :invoke
      end
    end
  end
end
