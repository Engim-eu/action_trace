# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    visit factory: %i[ahoy_visit]
    user

    name { 'page_visit' }
    properties { { path: '/areas', method: 'GET', controller: 'areas', action: 'index' } }
    time { Time.current }
  end
end
