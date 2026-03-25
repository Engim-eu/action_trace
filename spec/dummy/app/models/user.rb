# frozen_string_literal: true

class User < ApplicationRecord
  def complete_name
    "User ##{id}"
  end
end
