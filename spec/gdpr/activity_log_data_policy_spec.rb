# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityLogDataPolicy, type: :data_policy do
  fixtures :admin_users, :users, :organizations, :activity_logs

  subject(:policy) { described_class.new(request) }

  let(:request) do
    GdprAdmin::Request.create!(
      tenant: organizations(:beatles),
      requester: admin_users(:admin_user_a),
      request_type: 'erase_data',
      data_older_than: data_older_than,
    )
  end
  let(:data_older_than) { Time.new(2023, 2, 15) }

  describe '#scope' do
    it 'returns records older than given date' do
      expect(policy.scope.to_a).to contain_exactly(
        activity_logs(:anakin_activity_log_a),
        activity_logs(:john_activity_log_a),
        activity_logs(:john_activity_log_b),
      )
    end
  end

  describe '#erase' do
    describe 'when record has an IPv4' do
      let(:activity_log) { activity_logs(:john_activity_log_a) }

      it 'anonymizes the record data with masked IPv4' do
        policy.erase(activity_log)
        expect(activity_log.reload).to have_attributes(
          organization: organizations(:beatles),
          user: users(:john),
          sign_in_ip: '66.77.88.0',
          city: 'New York',
          region: 'NY',
          country: 'US',
          updated_at: Time.utc(2023, 2, 1),
        )
      end
    end

    describe 'when record has an IPv6' do
      let(:activity_log) { activity_logs(:john_activity_log_b) }

      it 'anonymizes the record data with masked IPv6' do
        policy.erase(activity_log)
        expect(activity_log.reload).to have_attributes(
          organization: organizations(:beatles),
          user: users(:john),
          sign_in_ip: '2001:db8:85a3::',
          city: 'Austin',
          region: 'TX',
          country: 'US',
          updated_at: Time.utc(2023, 2, 14),
        )
      end
    end
  end
end
