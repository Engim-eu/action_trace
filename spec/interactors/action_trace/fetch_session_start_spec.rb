# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::FetchSessionStarts, type: :interactor do
  let(:user)   { User.create! }
  let(:device) { Area.create! }

  let(:context) do
    Interactor::Context.new(
      filters: { 'source' => 'session_start' },
      source: 'session_start',
      current_user: user,
      company_id: user.company_id,
      user_id: user.id,
      range: 0,
      per_page: 20,
      total_count: 0,
      raw_collection: []
    )
  end

  describe '.call' do
    let!(:visit) { create(:ahoy_visit, user:, started_at: 1.hour.ago) }

    it 'adds ahoy visits to the raw_collection' do
      described_class.call(context)

      expect(context.raw_collection.first[:source]).to eq('session_start')
      expect(context.raw_collection.first[:id]).to eq("visit_#{visit.id}")
      expect(context.total_count).to eq(1)
    end

    it 'formats the visit data correctly' do
      described_class.call(context)
      entry = context.raw_collection.first

      expect(entry).to include(
        :id, :source, :occurred_at, :user, :subject, :details
      )
      expect(entry[:user]).to eq(user.complete_name)
    end

    context 'when source filter is different' do
      before { context.source = 'data_change' }

      it 'does not fetch visits' do
        described_class.call(context)
        expect(context.raw_collection).to be_empty
      end
    end

    context 'with date filters' do
      let!(:old_visit) { create(:ahoy_visit, user:, started_at: 2.days.ago) }
      let!(:new_visit) { create(:ahoy_visit, user:, started_at: Time.current) }

      it 'filters by start_date' do
        context.start_date = 1.day.ago.to_date.to_s
        described_class.call(context)

        ids = context.raw_collection.map { |e| e[:id] }
        expect(ids).to include("visit_#{new_visit.id}")
        expect(ids).not_to include("visit_#{old_visit.id}")
      end

      it 'filters by end_date' do
        context.end_date = 1.day.ago.to_date.to_s
        described_class.call(context)

        ids = context.raw_collection.map { |e| e[:id] }
        expect(ids).to include("visit_#{old_visit.id}")
        expect(ids).not_to include("visit_#{new_visit.id}")
      end
    end

    context 'with pagination' do
      before do
        create_list(:ahoy_visit, 5, user:)
        context.per_page = 2
      end

      it 'limits the results based on per_page' do
        described_class.call(context)
        expect(context.raw_collection.size).to eq(2)
      end
    end
  end
end
