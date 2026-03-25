# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::FetchDataChanges, type: :interactor do
  let(:user)   { User.create! }
  let(:device) { Area.create! }

  let(:context) do
    Interactor::Context.new(
      filters: { 'source' => 'data_change' },
      current_user: user,
      range: 0,
      per_page: 20,
      total_count: 0,
      raw_collection: []
    )
  end

  describe '.call' do
    it 'adds public activity records to the collection' do
      activity = device.create_activity(key: 'area.update', owner: user)

      described_class.call(context)
      expect(context.raw_collection.any? { |e| e[:id] == "act_#{activity.id}" }).to be true
    end

    it 'correctly identifies data_destroy source type' do
      activity = device.create_activity(key: 'area.destroy', owner: user)

      described_class.call(context)
      log_entry = context.raw_collection.find { |e| e[:id] == "act_#{activity.id}" }

      expect(log_entry[:source]).to eq(ActionTrace::ActivityLog::SOURCES[:data_destroy])
    end
  end
end
