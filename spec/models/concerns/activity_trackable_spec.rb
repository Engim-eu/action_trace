# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::DataTrackable, type: :model do
  let(:user) { create(:user) }
  let(:area) { build(:area) }

  before do
    allow(PublicActivity).to receive(:get_controller).and_return(double(current_user: user))
  end

  describe 'callbacks' do
    it 'tracks activity on create' do
      name = 'Test Area'
      area = FactoryBot.build(:area, name:)

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
