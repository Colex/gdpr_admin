# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDataPolicy, type: :data_policy do
  subject(:policy) { described_class.new(request) }

  let(:request) do
    GdprAdmin::Request.create!(
      tenant: tenant,
      requester: admin_user,
      request_type: 'erase_timeframe',
      data_older_than: data_older_than,
    )
  end
  let(:data_older_than) { 1.day.ago }
  let(:admin_user) { AdminUser.create!(name: 'John Doe', email: 'john.doe@admin.com') }
  let(:tenant) { Organization.create!(name: 'Acme') }
  let!(:user_a) do
    User.create!(
      organization: tenant,
      first_name: 'Eric',
      last_name: 'Clapton',
      email: 'eric.clapton@rock.fm',
      password_digest: '123456',
      updated_at: data_older_than - 1.day,
    )
  end
  let!(:user_b) do
    User.create!(
      organization: tenant,
      first_name: 'Ringo',
      last_name: 'Starr',
      email: 'ringo@beatles.com',
      password_digest: '123456',
      updated_at: data_older_than - 1.second,
    )
  end

  before do
    # Recent user record
    User.create!(
      organization: tenant,
      first_name: 'George',
      last_name: 'Harrison',
      email: 'george@beatles.co.uk',
      password_digest: '123456',
      updated_at: data_older_than,
    )
  end

  describe '#scope' do
    it 'returns records older than given date' do
      expect(policy.scope.to_a).to contain_exactly(user_a, user_b)
    end
  end

  describe '#erase' do
    it 'anonymizes the record' do
      policy.erase(user_a)
      expect(user_a.reload).to have_attributes(
        organization: tenant,
        first_name: 'Anonymized',
        last_name: "User #{user_a.id}",
        email: "anonymized.user#{user_a.id}@company.org",
        password_digest: a_string_matching(/(?!123456)/),
      )
    end
  end
end
