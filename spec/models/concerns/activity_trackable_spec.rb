# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::DataTrackable do
  let(:user) { create(:user) }
  let(:area) { build(:area) }

  before do
    allow(PublicActivity).to receive(:get_controller).and_return(double(current_user: user))
  end

  describe 'when host app defines a top-level Activity model' do
    # ponytail: define create so RSpec partial-double verification passes
    before { stub_const('Activity', Class.new { def self.create(*) = nil }) }

    it 'writes to PublicActivity::Activity, not the host Activity class' do
      allow(Activity).to receive(:create)
      expect { area.save! }.to change(PublicActivity::Activity, :count).by(1)
      expect(Activity).not_to have_received(:create)
    end
  end

  describe 'when model already has has_many :activities overriding the public_activity association' do
    # Replicates the scenario where a host app model (e.g. Company with GPS activities)
    # includes DataTrackable AND has its own has_many :activities pointing to a domain model.
    # The domain has_many :activities shadows the one added by PublicActivity::Common.
    before do
      stub_const('Activity', Class.new { def self.create(*) = nil })
      allow(Activity).to receive(:create)
      allow(area).to receive(:activities).and_return(Activity)
    end

    it 'still writes to PublicActivity::Activity via create_activity' do
      expect { area.save! }.to change(PublicActivity::Activity, :count).by(1)
      expect(Activity).not_to have_received(:create)
    end
  end

  describe 'callbacks' do
    it 'tracks activity on create' do
      name = 'Test Area'
      area = build(:area, name:)

      expect { area.save! }.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.where(trackable_id: area.id).last
      expect(activity.key).to eq('area.create')
      expect(activity.owner).to eq(user)
      expect(activity.parameters[:display_name]).to eq(name)
    end

    it 'tracks activity on update' do
      area.save!
      expect do
        area.update!(name: 'Updated Name')
      end.to change(PublicActivity::Activity, :count).by(1)

      expect(PublicActivity::Activity.last.key).to eq('area.update')
    end

    it 'tracks activity on destroy' do
      area.save!
      expect do
        area.destroy
      end.to change(PublicActivity::Activity, :count).by(1)

      expect(PublicActivity::Activity.last.key).to eq('area.destroy')
    end
  end
end
