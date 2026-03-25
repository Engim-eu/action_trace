# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActivityTrackable

  def current_user
    nil
  end
end
