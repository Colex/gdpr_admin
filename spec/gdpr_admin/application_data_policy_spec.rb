# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::ApplicationDataPolicy do
  subject(:policy) { described_class.new(request) }

  let(:request) { instance_double('GdprAdmin::Request') }

  describe '#scope' do
    it 'returns an empty collection' do
      expect(policy.scope.to_sql).to eql('SELECT "".* FROM "" WHERE (1=0)')
    end
  end

  describe '#erase' do
    it 'raises NotImplementedError' do
      expect { policy.erase(double) }.to raise_error(NotImplementedError)
    end
  end

  describe '#export' do
    it 'raises NotImplementedError' do
      expect { policy.export(double) }.to raise_error(NotImplementedError)
    end
  end
end
