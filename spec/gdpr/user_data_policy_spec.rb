# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDataPolicy, type: :data_policy do
  fixtures :admin_users, :organizations, :users

  subject(:policy) { described_class.new(request) }

  let(:request) do
    GdprAdmin::Request.create!(
      tenant: organizations(:beatles),
      requester: admin_users(:admin_user_a),
      request_type: 'erase_timeframe',
      data_older_than: data_older_than,
    )
  end
  let(:data_older_than) { Time.new(2023, 2, 15) }

  describe '#scope' do
    it 'returns records older than given date' do
      expect(policy.scope.to_a).to contain_exactly(
        users(:anakin),
        users(:leia),
        users(:paul),
        users(:george),
      )
    end
  end

  describe '#erase' do
    let(:user) { users(:john) }

    it 'anonymizes the record' do
      policy.erase(user)
      expect(user.reload).to have_attributes(
        organization: organizations(:beatles),
        first_name: 'Anonymized',
        last_name: "User #{user.id}",
        email: "anonymized.user#{user.id}@company.org",
        password_digest: a_string_matching(/(?!123456)/),
      )
    end
  end
end
