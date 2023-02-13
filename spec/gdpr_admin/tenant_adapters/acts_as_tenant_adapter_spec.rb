# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::TenantAdapters::ActsAsTenantAdapter do
  subject(:adapter) { described_class.new }

  describe '#with_tenant' do
    let(:tenant) { double(:tenant) } # rubocop:disable RSpec/VerifiedDoubles
    let(:block) { -> { :block } }

    it 'calls ActsAsTenant.with_tenant' do
      allow(ActsAsTenant).to receive(:with_tenant)
      adapter.with_tenant(tenant, &block)
      expect(ActsAsTenant).to have_received(:with_tenant).with(tenant, &block)
    end
  end
end
