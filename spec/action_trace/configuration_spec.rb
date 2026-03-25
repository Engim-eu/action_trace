# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'initializes excluded_actions as empty array' do
      expect(config.excluded_actions).to eq([])
    end

    it 'initializes excluded_controllers as empty array' do
      expect(config.excluded_controllers).to eq([])
    end
  end

  describe 'assignment' do
    it 'accepts excluded_actions' do
      config.excluded_actions = %w[status ping]
      expect(config.excluded_actions).to eq(%w[status ping])
    end

    it 'accepts excluded_controllers' do
      config.excluded_controllers = %w[home health]
      expect(config.excluded_controllers).to eq(%w[home health])
    end
  end

  describe 'ActionTrace.configure' do
    after { ActionTrace.instance_variable_set(:@configuration, nil) }

    it 'yields the configuration object' do
      ActionTrace.configure do |c|
        c.excluded_actions     = %w[status]
        c.excluded_controllers = %w[home]
      end

      expect(ActionTrace.configuration.excluded_actions).to eq(%w[status])
      expect(ActionTrace.configuration.excluded_controllers).to eq(%w[home])
    end

    it 'persists configuration across calls' do
      ActionTrace.configure { |c| c.excluded_actions = %w[ping] }
      expect(ActionTrace.configuration.excluded_actions).to eq(%w[ping])
    end
  end
end
