# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::RequestProcessorJob, type: :job do
  fixtures :admin_users, :organizations, :contacts, :users

  subject(:job) { described_class.new }

  describe '#perform' do
    context 'when the request is an erasure' do
      let(:request) do
        GdprAdmin::Request.create(
          tenant: organizations(:beatles),
          requester: admin_users(:admin_user_a),
          request_type: :erase_tenant,
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

      it 'does not anonymize users in other organizations' do
        job.perform(request)
        expect(organizations(:star_wars).users.to_a).to contain_exactly(
          have_attributes(
            id: users(:anakin).id,
            first_name: 'Anakin',
            last_name: 'Skywalker',
            email: 'anakin.skywalker@jedi.com',
            anonymized_at: nil,
            updated_at: Time.utc(2023, 2, 1),
          ),
          have_attributes(
            id: users(:leia).id,
            first_name: 'Leia',
            last_name: 'Organa',
            email: 'leia@royal.gov',
            anonymized_at: nil,
            updated_at: Time.utc(2023, 2, 1),
          ),
        )
      end

      it 'anonymizes all contacts in organization older than given date' do
        Timecop.freeze(anonymization_time) do
          job.perform(request)
        end
        expect(organizations(:beatles).contacts.to_a).to contain_exactly(
          have_attributes(
            id: contacts(:jerry).id,
            name: 'Jerry Seinfeld',
            first_name: 'Jerry',
            last_name: 'Seinfeld',
            gender: 'male',
            company: 'Comedians, Inc.',
            job_title: 'Comedian',
            email: 'jerry.seinfeld@comedians.com',
            phone_number: '212-555-1212',
            street_address1: '129 West 81st Street',
            city: 'New York',
            state: 'NY',
            zip: '10024',
            country: 'USA',
            country_code2: 'US',
            country_code3: 'USA',
            updated_at: Time.utc(2023, 2, 16),
            anonymized_at: nil,
          ),
          have_attributes(
            id: contacts(:kramer).id,
            name: 'Pres. Faustino Russel',
            first_name: 'Enrique',
            last_name: 'Daugherty',
            gender: 'male',
            company: 'Toy-Okuneva',
            job_title: nil,
            email: 'hertha@dooley.io',
            phone_number: '(704) 512-6951 x5536',
            street_address1: '9183 Desirae Underpass',
            city: 'Port Yessenia',
            state: 'Alaska',
            zip: '65787',
            country: 'United States Minor Outlying Islands',
            updated_at: Time.utc(2023, 2, 14),
            anonymized_at: anonymization_time,
          ),
          have_attributes(
            id: contacts(:george).id,
            name: 'Earnest Denesik',
            first_name: 'Lauri',
            last_name: 'Donnelly',
            gender: 'male',
            company: 'Wiza-Homenick',
            job_title: nil,
            email: 'chuck_heller@tillman-leffler.org',
            phone_number: '499-759-1958 x005',
            street_address1: '404 Faustino Throughway',
            street_address2: 'Apt. 396',
            city: 'Jacobsside',
            state: nil,
            zip: '83889-7464',
            country: 'Ecuador',
            updated_at: Time.utc(2023, 2, 1),
            anonymized_at: anonymization_time,
          ),
        )
      end

      it 'does not anonymize contacts in other organizations' do
        job.perform(request)
        expect(organizations(:star_wars).contacts.to_a).to contain_exactly(
          have_attributes(
            id: contacts(:hank).id,
            name: 'Hank Moody',
            first_name: 'Hank',
            last_name: 'Moody',
            gender: 'male',
            company: "Moody's Plumbing",
            job_title: 'Plumber',
            email: 'hank@moody.com',
            phone_number: '213-231-2313',
            street_address1: '78 East 2st Street',
            city: 'New York',
            state: 'NY',
            zip: '10018',
            country: 'USA',
            country_code2: 'US',
            country_code3: 'USA',
            updated_at: Time.utc(2023, 2, 1),
          ),
        )
      end

      it 'updates the request status to :completed' do
        job.perform(request)
      rescue StandardError
        expect(request.reload.status).to eql('completed')
      end

      it 'does not create new paper trail versions' do
        expect { job.perform(request) }.not_to change(PaperTrail::Version, :count)
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
