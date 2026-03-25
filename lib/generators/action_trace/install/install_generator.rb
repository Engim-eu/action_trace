# frozen_string_literal: true

require 'rails/generators'

module ActionTrace
  module Generators
    class InstallGenerator < Rails::Generators::Base
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
        generate 'ahoy:install' unless options[:skip_ahoy]
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

      def show_post_install_message
        readme 'POST_INSTALL' if behavior == :invoke
      end
    end
  end
end
