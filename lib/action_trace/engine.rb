# frozen_string_literal: true

module ActionTrace
  class Engine < ::Rails::Engine
    isolate_namespace ActionTrace

    config.generators do |g|
      g.test_framework :rspec
    end

    config.after_initialize do
      begin
        user_class = ActionTrace.configuration.user_class.constantize
      rescue NameError
        raise NameError,
              "ActionTrace: user_class '#{ActionTrace.configuration.user_class}' not found. Check config/initializers/action_trace.rb."
      end

      PublicActivity::Activity.define_singleton_method(:filter_by_company) do |scope, company_id|
        user_ids = user_class.where(company_id: company_id).select(:id)
        scope.where(owner_type: user_class.name, owner_id: user_ids)
      end

      [Ahoy::Visit, Ahoy::Event].each do |klass|
        klass.define_singleton_method(:filter_by_company) do |scope, company_id|
          user_ids = user_class.where(company_id: company_id).select(:id)
          scope.where(user_id: user_ids)
        end
      end
    end
  end
end
