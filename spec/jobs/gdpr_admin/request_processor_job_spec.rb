# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::RequestProcessorJob, type: :job do
  fixtures :admin_users, :organizations, :users

  subject(:job) { described_class.new }

  describe '#perform' do
    context 'when the request is an erasure' do
      let(:request) do
        GdprAdmin::Request.create(
          tenant: organizations(:beatles),
          requester: admin_users(:admin_user_a),
          request_type: :erase_all,
          data_older_than: Time.new(2023, 2, 15),
        )
      end
      let(:anonymization_time) { Time.utc(2023, 2, 1, 0, 20) }

      it 'anonymizes all users in organization older than given date' do
        Timecop.freeze(anonymization_time) do
          job.perform(request)
        end
        expect(organizations(:beatles).users.to_a).to contain_exactly(
          have_attributes(
            id: users(:john).id,
            first_name: 'John',
            last_name: 'Lennon',
            email: 'john.lennon@thebeatles.com',
            anonymized_at: nil,
          ),
          have_attributes(
            id: users(:paul).id,
            first_name: 'Anonymized',
            last_name: "User #{users(:paul).id}",
            email: "anonymized.user#{users(:paul).id}@company.org",
            anonymized_at: anonymization_time,
          ),
          have_attributes(
            id: users(:george).id,
            first_name: 'Anonymized',
            last_name: "User #{users(:george).id}",
            email: "anonymized.user#{users(:george).id}@company.org",
            anonymized_at: anonymization_time,
          ),
        )
      end

      it 'updates the request status to :completed' do
        job.perform(request)
      rescue StandardError
        expect(request.reload.status).to eql('completed')
      end

      context 'when request fails to process' do
        before do
          allow_any_instance_of(UserDataPolicy).to receive(:erase).and_raise(StandardError) # rubocop:disable RSpec/AnyInstance
        end

        it 'updates the request status to :failed' do
          job.perform(request)
        rescue StandardError
          expect(request.reload.status).to eql('failed')
        end
      end
    end
  end
end
