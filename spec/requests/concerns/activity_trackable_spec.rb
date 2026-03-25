# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityTrackable, type: :controller do
  controller(ApplicationController) do
    def index
      render plain: 'ok'
    end

    def index_failure
      render plain: 'not found', status: :not_found
    end
  end

  let(:user) { double('User', company_id: 42) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    routes.draw do
      get 'index'         => 'anonymous#index'
      get 'index_failure' => 'anonymous#index_failure'
    end
  end

  after do
    Rails.application.reload_routes!
    ActionTrace.instance_variable_set(:@configuration, nil)
  end

  describe '#track_action (after_action hook)' do
    it 'tracks a page_visit event with request metadata when request is successful and user is logged in' do
      expect(controller.ahoy).to receive(:track).with(
        ActionTrace::ActivityLog::SOURCES[:page_visit],
        hash_including(
          method: 'GET',
          controller: 'anonymous',
          action: 'index',
          company_id: 42
        )
      )

      get :index
    end

    it 'does not track when current_user is nil' do
      allow(controller).to receive(:current_user).and_return(nil)
      expect(controller.ahoy).not_to receive(:track)
      get :index
    end

    it 'when response is not successful does not track' do
      expect(controller.ahoy).not_to receive(:track)
      get :index_failure
    end

    it 'does not track when controller is in excluded_controllers' do
      ActionTrace.configure { |c| c.excluded_controllers = %w[anonymous] }
      expect(controller.ahoy).not_to receive(:track)
      get :index
    end

    it 'does not track when action is in excluded_actions' do
      ActionTrace.configure { |c| c.excluded_actions = %w[index] }
      expect(controller.ahoy).not_to receive(:track)
      get :index
    end
  end

  describe '#track_session_end' do
    let(:visit) { double('Visit', id: 99) }

    before do
      allow(controller.ahoy).to receive(:visit).and_return(visit)
      allow(controller.ahoy).to receive(:reset_visit)
    end

    it 'tracks a session_end event with logout reason and visit_id' do
      expect(controller.ahoy).to receive(:track).with(
        ActionTrace::ActivityLog::SOURCES[:session_end],
        hash_including(reason: 'logout', visit_id: 99)
      )
      expect(controller.ahoy).to receive(:reset_visit)

      controller.send(:track_session_end)
    end

    context 'when there is no active visit' do
      before { allow(controller.ahoy).to receive(:visit).and_return(nil) }

      it 'tracks with visit_id nil' do
        expect(controller.ahoy).to receive(:track).with(
          ActionTrace::ActivityLog::SOURCES[:session_end],
          hash_including(reason: 'logout', visit_id: nil)
        )
        expect(controller.ahoy).to receive(:reset_visit)

        controller.send(:track_session_end)
      end
    end
  end

  describe '#current_company_id' do
    it 'returns current_user company_id' do
      expect(controller.send(:current_company_id)).to eq(user.company_id)
    end

    it 'returns nil when current_user is nil' do
      allow(controller).to receive(:current_user).and_return(nil)
      expect(controller.send(:current_company_id)).to be_nil
    end
  end
end
