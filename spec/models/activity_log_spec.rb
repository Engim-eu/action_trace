# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::ActivityLog do
  subject { described_class.new(attributes) }

  let(:user) { create(:user) }
  let(:attributes) do
    {
      id: 1,
      source: 'page_visit',
      occurred_at: Time.current,
      user: user,
      subject: 'Test Subject',
      details: { path: '/test' },
      trackable_type: 'User'
    }
  end

  describe '#initialize' do
    it 'assigns attributes correctly' do
      expect(subject.id).to eq(1)
      expect(subject.source).to eq('page_visit')
      expect(subject.user).to eq(user)
      expect(subject.details).to eq({ path: '/test' })
      expect(subject.url).to be_nil
    end

    it 'defaults details to empty hash if nil' do
      log = described_class.new(details: nil)
      expect(log.details).to eq({})
    end
  end

  describe 'source predicates' do
    it 'returns true for page_visit?' do
      expect(subject.page_visit?).to be true
    end

    it 'returns true for data_create?' do
      log = described_class.new(source: 'data_create')
      expect(log.data_create?).to be true
    end

    it 'returns true for data_change?' do
      log = described_class.new(source: 'data_change')
      expect(log.data_change?).to be true
    end

    it 'returns true for data_destroy?' do
      log = described_class.new(source: 'data_destroy')
      expect(log.data_destroy?).to be true
    end

    it 'returns true for session_start?' do
      log = described_class.new(source: 'session_start')
      expect(log.session_start?).to be true
    end

    it 'returns false for other predicates' do
      expect(subject.data_create?).to be false
      expect(subject.session_start?).to be false
    end
  end

  describe '#human_trackable_type' do
    it 'returns the humanized name of the model' do
      expect(subject.human_trackable_type).to eq(User.model_name.human)
    end

    it 'returns nil if trackable_type is blank' do
      log = described_class.new(trackable_type: nil)
      expect(log.human_trackable_type).to be_nil
    end

    it 'returns the raw string if the constant cannot be found (rescue block)' do
      log = described_class.new(trackable_type: 'NonExistentModel')
      expect(log.human_trackable_type).to eq('NonExistentModel')
    end
  end
end
