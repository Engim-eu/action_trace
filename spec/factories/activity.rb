# frozen_string_literal: true

FactoryBot.define do
  factory :activity, class: 'PublicActivity::Activity' do
    association :owner, factory: :user
    association :trackable, factory: :area
    key { 'area.update' }
    parameters { {} }
  end
end
