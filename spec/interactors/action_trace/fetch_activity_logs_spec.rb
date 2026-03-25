# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::FetchActivityLogs, type: :interactor do
  describe '.call' do
    let(:params) { { filters: {}, current_user: double(:user, company_id: 1), range: 0 } }

    it 'organizes all the activity log fetchers' do
      expect(described_class.organized).to eq([
                                                ActionTrace::InitializeContext,
                                                ActionTrace::FetchDataChanges,
                                                ActionTrace::FetchPageVisits,
                                                ActionTrace::FetchSessionStarts,
                                                ActionTrace::MergeAndFormatResults
                                              ])
    end

    it 'succeeds with valid params' do
      result = described_class.call(params)
      expect(result).to be_a_success
    end
  end

  describe 'ActivityLogFetchable' do
    let(:context) { Interactor::Context.new(source: nil, company_id: nil, user_id: nil) }
    let(:instance) { ActionTrace::FetchDataChanges.new(context) }

    describe '#should_fetch?' do
      it 'returns true if context.source is blank' do
        expect(instance.should_fetch?('any_type')).to be true
      end

      it 'returns true if source matches source_type' do
        context.source = 'page_visit'
        expect(instance.should_fetch?('page_visit')).to be true
      end

      context 'with data related source_types' do
        it 'returns true for data_change and data_destroy when source is data_change' do
          context.source = ActionTrace::ActivityLog::SOURCES[:data_change]
          expect(instance.should_fetch?('data_change')).to be true
          expect(instance.should_fetch?('data_destroy')).to be true
        end

        it 'returns true for data_change when source is data_create' do
          context.source = ActionTrace::ActivityLog::SOURCES[:data_create]
          expect(instance.should_fetch?('data_change')).to be true
        end

        it 'returns false for unrelated types' do
          context.source = ActionTrace::ActivityLog::SOURCES[:data_change]
          expect(instance.should_fetch?('page_visit')).to be false
        end
      end
    end

    describe '#base_scope' do
      let(:company) { double(:company, id: 1) }
      let(:user) { double(:user, id: 2) }

      before do
        stub_const('Area', Class.new(ActiveRecord::Base) { self.table_name = 'areas' })
      end

      it 'filters by company_id when present' do
        context.company_id = company.id
        expect(instance.base_scope(Area).to_sql).to match(/["`]areas["`]\.["`]company_id["`] = #{company.id}/)
      end

      it 'filters by user_id when present' do
        context.user_id = user.id
        expect(instance.base_scope(Area).to_sql).to match(/["`]areas["`]\.["`]user_id["`] = #{user.id}/)
      end

      context 'with PublicActivity::Activity' do
        it 'uses owner_id for user filter' do
          context.user_id = user.id
          expect(instance.base_scope(PublicActivity::Activity).to_sql).to match(/["`]activities["`]\.["`]owner_id["`] = #{user.id}/)
        end

        it 'applies type filter for data_create' do
          context.source = ActionTrace::ActivityLog::SOURCES[:data_create]
          expect(instance.base_scope(PublicActivity::Activity).to_sql).to include("activities.`key` LIKE '%.create'")
        end
      end

      context 'with date filters (SQL Injection Safety)' do
        let(:start_date) { '2026-01-01' }
        let(:end_date) { '2026-01-16' }

        before do
          context.start_date = start_date
          context.end_date = end_date
        end

        it 'produces correct >= SQL for start_date using new hash syntax' do
          sql = instance.base_scope(Area).to_sql
          expect(sql).to match(/["`]areas["`]\.["`]created_at["`] >= '2026-01-01 00:00:00'/)
        end

        it 'produces correct <= SQL for end_date using new hash syntax' do
          sql = instance.base_scope(Area).to_sql
          expect(sql).to match(/["`]areas["`]\.["`]created_at["`] <= '2026-01-16 23:59:59/)
        end

        it 'uses the correct table and column for Ahoy::Visit' do
          sql = instance.base_scope(Ahoy::Visit).to_sql
          expect(sql).to match(/["`]ahoy_visits["`]\.["`]started_at["`] >= '2026-01-01 00:00:00'/)
        end

        it 'uses the correct table and column for Ahoy::Event' do
          sql = instance.base_scope(Ahoy::Event).to_sql
          expect(sql).to match(/["`]ahoy_events["`]\.["`]time["`] >= '2026-01-01 00:00:00'/)
        end

        it 'is resilient to invalid date formats' do
          context.start_date = 'invalid-date'
          expect { instance.base_scope(Area) }.not_to raise_error
        end
      end

      describe '#apply_activity_type_filter' do
        it 'returns the original scope if source is blank' do
          context.source = nil
          sql = instance.base_scope(PublicActivity::Activity).to_sql
          expect(sql).not_to include('LIKE')
        end

        it 'filters for data_create (.create)' do
          context.source = ActionTrace::ActivityLog::SOURCES[:data_create]
          sql = instance.base_scope(PublicActivity::Activity).to_sql
          expect(sql).to include("activities.`key` LIKE '%.create'")
        end

        it 'filters for data_change (.update)' do
          context.source = ActionTrace::ActivityLog::SOURCES[:data_change]
          sql = instance.base_scope(PublicActivity::Activity).to_sql
          expect(sql).to include("activities.`key` LIKE '%.update'")
        end

        it 'filters for data_destroy (.destroy)' do
          context.source = ActionTrace::ActivityLog::SOURCES[:data_destroy]
          sql = instance.base_scope(PublicActivity::Activity).to_sql
          expect(sql).to include("activities.`key` LIKE '%.destroy'")
        end

        it 'returns original scope for unknown sources' do
          context.source = 'unknown_source'
          sql = instance.base_scope(PublicActivity::Activity).to_sql
          expect(sql).not_to include('LIKE')
        end
      end
    end
  end
end
