# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::MergeAndFormatResults, type: :interactor do
  let(:context) do
    Interactor::Context.new(
      raw_collection: raw_data,
      per_page: 2,
      total_count: 10
    )
  end

  let(:raw_data) do
    [
      { id: 1, occurred_at: 2.hours.ago, source: 'page_visit' },
      { id: 2, occurred_at: 1.hour.ago, source: 'session_start' },
      { id: 3, occurred_at: 3.hours.ago, source: 'data_change' }
    ]
  end

  describe '.call' do
    it 'sorts results by occurred_at in descending order' do
      described_class.call(context)

      expect(context.activity_logs.first.id).to eq(2)
      expect(context.activity_logs.second.id).to eq(1)
    end

    it 'limits the results to per_page' do
      described_class.call(context)

      expect(context.activity_logs.size).to eq(2)
    end

    it 'converts raw hashes into ActivityLog objects' do
      described_class.call(context)

      expect(context.activity_logs.first).to be_an_instance_of(ActionTrace::ActivityLog)
    end

    it 'defines a total_count method on the results collection' do
      described_class.call(context)

      expect(context.activity_logs).to respond_to(:total_count)
      expect(context.activity_logs.total_count).to eq(10)
    end

    context 'with empty collection' do
      let(:raw_data) { [] }

      it 'succeeds and returns an empty array' do
        result = described_class.call(context)

        expect(result).to be_a_success
        expect(context.activity_logs).to be_empty
      end
    end
  end
end
