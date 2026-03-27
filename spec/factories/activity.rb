# frozen_string_literal: true

FactoryBot.define do
  factory :activity, class: 'PublicActivity::Activity' do
    owner factory: %i[user]
    trackable factory: %i[area]
    key { 'area.update' }
    parameters { {} }
  end
end
