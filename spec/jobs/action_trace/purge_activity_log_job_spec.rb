# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::PurgeActivityLogJob, type: :job do
  describe '#perform' do
    let(:old_date) { 14.months.ago }
    let(:recent_date) { 6.months.ago }

    after { ActionTrace.instance_variable_set(:@configuration, nil) }

    it 'purges records older than the configured retention period' do
      old_activity = create(:activity, created_at: old_date)
      old_event = create(:ahoy_event, time: old_date)
      old_visit = create(:ahoy_visit, started_at: old_date)

      recent_activity = create(:activity, created_at: recent_date)
      recent_event = create(:ahoy_event, time: recent_date)
      recent_visit = create(:ahoy_visit, started_at: recent_date)

      expect do
        described_class.perform_now
      end.to change(PublicActivity::Activity, :count).by(-1)
                                                     .and change(Ahoy::Event, :count).by(-1)
                                                                                     .and change(Ahoy::Visit,
                                                                                                 :count).by(-1)

      expect(PublicActivity::Activity.exists?(recent_activity.id)).to be true
      expect(Ahoy::Event.exists?(recent_event.id)).to be true
      expect(Ahoy::Visit.exists?(recent_visit.id)).to be true

      expect(PublicActivity::Activity.exists?(old_activity.id)).to be false
      expect(Ahoy::Event.exists?(old_event.id)).to be false
      expect(Ahoy::Visit.exists?(old_visit.id)).to be false
    end

    it 'respects a custom log_retention_period' do
      ActionTrace.configure { |c| c.log_retention_period = 3.months }

      old_activity = create(:activity, created_at: 4.months.ago)
      recent_activity = create(:activity, created_at: 2.months.ago)

      expect do
        described_class.perform_now
      end.to change(PublicActivity::Activity, :count).by(-1)

      expect(PublicActivity::Activity.exists?(recent_activity.id)).to be_truthy
      expect(PublicActivity::Activity.exists?(old_activity.id)).to be_falsey
    end
  end
end
