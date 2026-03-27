# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::ActivityLogsController, type: :controller do
  routes { ActionTrace::Engine.routes }

  let(:user) { double('User', company_id: 42) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    let(:interactor_result) { double(success?: true, activity_logs: [], total_count: 0) }

    it 'calls FetchActivityLogs interactor' do
      expect(ActionTrace::FetchActivityLogs).to receive(:call).with(
        hash_including(current_user: user)
      ).and_return(interactor_result)

      get :index
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end

    it 'handles interactor failure' do
      failure_result = double(success?: false, message: 'error')
      allow(ActionTrace::FetchActivityLogs).to receive(:call).and_return(failure_result)

      get :index
      expect(flash[:error]).to eq('error')
      expect(assigns(:activity_logs)).to eq([])
      expect(assigns(:activity_logs_count)).to eq(0)
    end

    it 'responds to xhr request' do
      allow(ActionTrace::FetchActivityLogs).to receive(:call).and_return(interactor_result)

      get :index, xhr: true
      expect(response).to have_http_status(:ok)
      expect(response.headers['Cache-Control']).to eq('no-store')
      expect(response).to render_template(partial: '_index')
    end

    it 'uses filters from session' do
      filters = { 'action_type' => 'create' }
      post :filter, params: { filters: filters }

      expect(ActionTrace::FetchActivityLogs).to receive(:call).with(
        hash_including(filters: ActionController::Parameters.new(filters))
      ).and_return(interactor_result)

      get :index
    end

    it 'reset filters from session' do
      filters = { 'action_type' => 'create' }
      post :filter, params: { reset: true, filters: filters }

      expect(session[:activity_logs_filters]).to be_blank
    end
  end
end
