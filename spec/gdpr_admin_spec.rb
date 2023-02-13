# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin, type: :lib do
  it 'has a version number' do
    expect(GdprAdmin::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  describe '.configure' do
    it 'yields the configuration' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.config)
    end
  end

  describe '.config' do
    it 'returns a configuration' do
      expect(described_class.config).to be_a(GdprAdmin::Configuration)
    end

    it 'returns the same configuration' do
      expect(described_class.config).to eql(described_class.config) # rubocop:disable RSpec/IdenticalEqualityAssertion
    end
  end

  describe '.load_data_policies' do
    before do
      described_class.config.data_policies_path = File.join(File.dirname(__FILE__), 'mock_gdpr')
    end

    after do
      described_class.config.data_policies_path = Rails.root.join('app', 'gdpr')
    end

    it 'loads data policies' do
      described_class.load_data_policies
      expect(GdprAdmin::ApplicationDataPolicy.descendants).to include(MockDataPolicy)
    end
  end
end
