# frozen_string_literal: true

Rails.application.routes.draw do
  mount ActionTrace::Engine => '/action_trace'
end
