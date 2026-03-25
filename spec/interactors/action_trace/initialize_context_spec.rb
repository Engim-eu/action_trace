# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionTrace::InitializeContext, type: :interactor do
  describe '.call' do
    let(:user) { create(:user) }

    it 'sets up default pagination and collections' do
      result = described_class.call(filters: {}, current_user: user, range: 0)

      expect(result.per_page).to eq(50)
      expect(result.total_count).to eq(0)
      expect(result.raw_collection).to eq([])
    end
  end
end
