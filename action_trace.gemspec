# frozen_string_literal: true

require_relative 'lib/action_trace/version'

Gem::Specification.new do |spec|
  spec.name        = 'action_trace'
  spec.version     = ActionTrace::VERSION
  spec.authors     = ['gimbaro']
  spec.email       = ['me@gimbaro.dev']
  spec.summary     = 'A Rails engine that consolidates user interaction tracking into a single integration'
  spec.description = 'ActionTrace glues together public_activity, ahoy_matey, paper_trail, and discard ' \
                     'to provide a unified interface for activity tracking, visit analytics, ' \
                     'model versioning, and soft deletes in Rails applications.'
  spec.license     = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'ahoy_matey', '>= 5'
  spec.add_dependency 'discard', '>= 1'
  spec.add_dependency 'interactor', '> 3'
  spec.add_dependency 'paper_trail', '>= 17'
  spec.add_dependency 'public_activity', '>= 3'
  spec.add_dependency 'rails', '>= 7'

  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'rails-controller-testing'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rails'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
