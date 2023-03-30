# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationDataPolicy, type: :data_policy do
  fixtures :admin_users, :organizations, :contacts

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

  describe '#process' do
    it 'skips the policy' do
      expect(policy.process).to be_nil
    end
  end
end
