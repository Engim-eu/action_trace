# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    association :visit, factory: :ahoy_visit
    association :user

    name { 'page_visit' }
    properties { { path: '/areas', method: 'GET', controller: 'areas', action: 'index' } }
    time { Time.current }
  end
end
