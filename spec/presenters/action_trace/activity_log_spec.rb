# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::ActivityLogPresenter, type: :presenter do
  let(:log_class) do
    Class.new do
      attr_reader :source, :raw_subject, :details

      include ActionTrace::ActivityLogPresenter

      def initialize(source:, raw_subject: nil, details: {})
        @source = source
        @raw_subject = raw_subject
        @details = details.stringify_keys
      end
    end
  end

  describe '#icon and #color' do
    it 'returns correct visual config for data_create' do
      presenter = log_class.new(source: 'data_create')
      expect(presenter.icon).to eq('fas fa-plus-circle')
      expect(presenter.color).to eq('text-success')
    end

    it 'returns default visual config for unknown source' do
      presenter = log_class.new(source: 'unknown')
      expect(presenter.icon).to eq('fas fa-globe-pointer')
      expect(presenter.color).to eq('text-secondary')
    end
  end

  describe '#subject' do
    context 'when source is data_change' do
      it 'returns the raw_subject' do
        presenter = log_class.new(source: 'data_change', raw_subject: 'Original Subject')
        expect(presenter.subject).to eq('Original Subject')
      end
    end

    context 'when source is page_visit' do
      it 'returns the path if controller is missing' do
        presenter = log_class.new(source: 'page_visit', details: { path: '/home' })
        expect(presenter.subject).to eq('/home')
      end

      it 'formats correctly for a known model (e.g., Area index)' do
        presenter = log_class.new(source: 'page_visit', details: { controller: 'areas', action: 'index' })
        expect(presenter.subject).to include(Area.model_name.human(count: 2))
      end

      it 'formats correctly for a new record (e.g., Device new)' do
        presenter = log_class.new(source: 'page_visit', details: { controller: 'devices', action: 'new' })
        expect(presenter.subject).to include(Device.model_name.human)
      end

      it 'formats correctly for a show action (e.g., Owner show)' do
        presenter = log_class.new(source: 'page_visit', details: { controller: 'owners', action: 'show' })
        expect(presenter.subject).to include(Owner.model_name.human)
      end

      it 'formats correctly for a create action (mapped to new)' do
        presenter = log_class.new(source: 'page_visit', details: { controller: 'areas', action: 'create' })
        expect(presenter.subject).to include(Area.model_name.human)
      end

      it 'formats correctly for an update action (mapped to edit)' do
        presenter = log_class.new(source: 'page_visit', details: { controller: 'devices', action: 'update' })
        expect(presenter.subject).to include(Device.model_name.human)
      end

      it 'formats correctly for a destroy action (mapped to destroy)' do
        presenter = log_class.new(source: 'page_visit', details: { controller: 'areas', action: 'destroy' })
        expect(presenter.subject).to include(Area.model_name.human)
      end

      it 'falls back to humanized string if model constant is not found' do
        presenter = log_class.new(source: 'page_visit', details: { controller: 'non_existent_things', action: 'index' })
        expect(presenter.subject).to include('Non existent things')
      end

      it 'returns the path for an unknown action' do
        presenter = log_class.new(source: 'page_visit',
                                  details: { controller: 'areas', action: 'unknown',
                                             path: '/areas/unknown' })
        expect(presenter.subject).to eq('/areas/unknown')
      end
    end
  end
end
