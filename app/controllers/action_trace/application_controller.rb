# frozen_string_literal: true

module ActionTrace
  class ApplicationController < ::ApplicationController
    helper do
      def method_missing(method_name, *args, &block)
        if method_name.to_s.end_with?('_path', '_url') && main_app.respond_to?(method_name)
          main_app.public_send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        (method_name.to_s.end_with?('_path', '_url') && main_app.respond_to?(method_name)) || super
      end
    end
  end
end
