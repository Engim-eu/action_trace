# frozen_string_literal: true

ActionTrace.configure do |config|
  # config.excluded_actions     = %w[status ping]
  # config.excluded_controllers = %w[home]
end

module Ahoy
  class Store < Ahoy::DatabaseStore
  end
end

Ahoy.api      = false
Ahoy.geocode  = false
Ahoy.mask_ips = true
Ahoy.cookies  = true

PaperTrail.config do |config|
  config.enabled       = true
  config.version_limit = 10
  config.serializer    = PaperTrail::Serializers::JSON
end

PublicActivity::Config.set do
  enabled true
end
