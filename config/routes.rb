# frozen_string_literal: true

ActionTrace::Engine.routes.draw do
  resources :activity_logs, only: [:index] do
    collection do
      post :filter
    end
  end
end
