# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::Configuration do
  subject(:config) { described_class.new }

  describe '#tenant_adapter' do
    context 'when tenant_adapter is a symbol' do
      before do
        config.tenant_adapter = :acts_as_tenant
      end

      it 'returns the corresponding adapter' do
        expect(config.tenant_adapter).to be_a(GdprAdmin::TenantAdapters::ActsAsTenantAdapter)
      end
    end

    context 'when tenant_adapter is not a symbol' do
      let(:adapter) { GdprAdmin::TenantAdapters::ActsAsTenantAdapter.new }

      before do
        config.tenant_adapter = adapter
      end

      it 'returns the tenant_adapter' do
        expect(config.tenant_adapter).to eql(adapter)
      end
    end
  end
end
