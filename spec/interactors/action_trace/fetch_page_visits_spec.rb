# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::FetchPageVisits, type: :interactor do
  let(:user)   { User.create! }
  let(:device) { Area.create! }

  let(:context) do
    Interactor::Context.new(
      filters: { 'source' => 'page_visit' },
      current_user: user,
      range: 0,
      per_page: 20,
      total_count: 0,
      raw_collection: []
    )
  end

  describe '.call' do
    it 'adds ahoy events to the raw_collection' do
      create(:ahoy_event, name: 'page_visit', user: user, time: Time.current)

      described_class.call(context)

      expect(context.raw_collection.first[:source]).to eq('page_visit')
      expect(context.total_count).to eq(1)
    end

    it 'filters session_end correctly' do
      context.filters['source'] = ActionTrace::ActivityLog::SOURCES[:session_end]
      context.source = ActionTrace::ActivityLog::SOURCES[:session_end]

      create(:ahoy_event, name: 'session_end', user: user)
      create(:ahoy_event, name: 'page_visit', user: user)

      described_class.call(context)

      expect(context.raw_collection.all? { |e| e[:source] == 'session_end' }).to be true
      expect(context.total_count).to eq(1)
    end

    it 'filters page_visit correctly' do
      context.filters['source'] = ActionTrace::ActivityLog::SOURCES[:page_visit]
      context.source = ActionTrace::ActivityLog::SOURCES[:page_visit]

      create(:ahoy_event, name: 'session_end', user: user)
      create(:ahoy_event, name: 'page_visit', user: user)

      described_class.call(context)

      expect(context.raw_collection.all? { |e| e[:source] == 'page_visit' }).to be true
      expect(context.total_count).to eq(1)
    end

    it 'returns all events when no source filter is applied (default case)' do
      context.filters['source'] = nil
      context.source = nil

      create(:ahoy_event, name: 'page_visit', user: user)
      create(:ahoy_event, name: 'session_end', user: user)

      described_class.call(context)

      expect(context.total_count).to eq(2)
    end
  end
end
