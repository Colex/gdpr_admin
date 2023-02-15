# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::PaperTrail::VersionDataPolicy do
  subject(:version_data_policy) { described_class.new(request) }

  let(:request) { instance_double('GdprAdmin::Request') }

  describe '#scope' do
    it 'returns an empty set' do
      expect(version_data_policy.scope.to_sql).to eql('SELECT "versions".* FROM "versions" WHERE (1=0)')
    end
  end

  describe '#fields' do
    it 'returns an empty array by default' do
      expect(version_data_policy.fields).to eql([])
    end
  end
end
