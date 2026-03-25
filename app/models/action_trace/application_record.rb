# frozen_string_literal: true

module ActionTrace
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
