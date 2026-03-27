# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_visit, class: 'Ahoy::Visit' do
    user
    visit_token { SecureRandom.uuid }
    visitor_token { SecureRandom.uuid }
    started_at { Time.current }
    ip { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
  end
end
