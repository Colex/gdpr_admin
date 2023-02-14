# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactDataPolicy, type: :data_policy do
  fixtures :admin_users, :organizations, :contacts

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
        contacts(:kramer),
        contacts(:george),
        contacts(:hank),
      )
    end
  end

  describe '#erase' do
    let(:contact) { contacts(:jerry) }

    it 'anonymizes the record data' do
      policy.erase(contact)
      expect(contact.reload).to have_attributes(
        organization: organizations(:beatles),
        first_name: 'Deshawn',
        last_name: 'Schamberger',
        company: 'Konopelski, Dooley and Wintheiser',
        job_title: nil,
        email: 'helaine.wolf@sporer.info',
        phone_number: '445.983.7363 x6175',
        street_address1: '87945 Lesch Orchard',
        city: 'Port Yessenia',
        state: 'Alaska',
        zip: '81189-3837',
        country: 'United States Minor Outlying Islands',
        updated_at: Time.utc(2023, 2, 16),
      )
    end
  end
end
