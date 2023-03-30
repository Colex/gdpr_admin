# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaperTrail::VersionDataPolicy do
  fixtures 'paper_trail/versions'

  subject(:version_data_policy) { described_class.new(request) }

  let(:request) { instance_double('GdprAdmin::Request') }

  describe '#scope' do
    it 'returns an empty set' do
      expect(version_data_policy.scope.to_sql).to eql('SELECT "versions".* FROM "versions" WHERE (1=0)')
    end
  end

  describe '#anonymize' do
    before do
      GdprAdmin.load_data_policies
    end

    context "when item's data policy is defined" do
      let(:version) { paper_trail_versions(:jerry1) }

      context 'when fields are not explicitly given' do
        it "anonymizes version with fields from item's policy" do
          version_data_policy.erase(version)
          expect(version.reload).to have_attributes(
            id: version.id,
            item_type: version.item_type,
            item_id: version.item_id,
            event: version.event,
            whodunnit: version.whodunnit,
            ip: '169.246.254.240',
            object: {
              'name' => 'Anamaria Keeling Sr.',
              'first_name' => 'Deshawn',
              'last_name' => 'Schamberger',
              'gender' => 'male',
              'company' => 'Konopelski, Dooley and Wintheiser',
              'job_title' => nil,
              'email' => 'helaine.wolf@sporer.info',
              'phone_number' => '445.983.7363 x6175',
              'street_address1' => '87945 Lesch Orchard',
              'city' => 'Port Yessenia',
              'state' => 'Alaska',
              'zip' => '81189-3837',
              'country' => 'United States Minor Outlying Islands',
              'country_code2' => 'SZ',
              'country_code3' => 'UKR',
            },
            object_changes: {
              'name' => ['Mr. Damien Dicki', 'Anamaria Keeling Sr.'],
              'first_name' => %w[Gertrudis Deshawn],
              'last_name' => [nil, 'Schamberger'],
              'gender' => %w[female male],
              'job_title' => [nil, nil],
            },
            created_at: version.created_at,
          )
        end
      end

      context 'when fields are explicitly given' do
        let(:fields) do
          [
            { field: :name, method: :anonymize_name },
            { field: :first_name, method: :anonymize_first_name },
            { field: :last_name, method: :anonymize_last_name },
            { field: :gender, method: :nullify },
          ]
        end

        it 'anonymizes given fields in version' do
          version_data_policy.erase(version, fields)
          expect(version.reload).to have_attributes(
            id: version.id,
            item_type: version.item_type,
            item_id: version.item_id,
            event: version.event,
            whodunnit: version.whodunnit,
            ip: '169.246.254.240',
            object: {
              'name' => 'Anamaria Keeling Sr.',
              'first_name' => 'Deshawn',
              'last_name' => 'Schamberger',
              'gender' => nil,
              'company' => 'Comedians, Inc.',
              'job_title' => 'Comedian',
              'email' => 'jerry.seinfeld@comedians.com',
              'phone_number' => '212-555-1212',
              'street_address1' => '129 West 81st Street',
              'city' => 'New York',
              'state' => 'NY',
              'zip' => '10024',
              'country' => 'USA',
              'country_code2' => 'US',
              'country_code3' => 'USA',
            },
            object_changes: {
              'name' => ['Mr. Damien Dicki', 'Anamaria Keeling Sr.'],
              'first_name' => %w[Gertrudis Deshawn],
              'last_name' => [nil, 'Schamberger'],
              'gender' => [nil, nil],
              'job_title' => %w[Unemployed Comedian],
            },
            created_at: version.created_at,
          )
        end
      end
    end

    context "when item's data policy is not defined" do
      let(:version) { paper_trail_versions(:admin_user1) }

      context 'when fields are not explicitly given' do
        it "does not anonymize version's object" do
          version_data_policy.erase(version)
          expect(version.reload).to have_attributes(
            id: version.id,
            item_type: version.item_type,
            item_id: version.item_id,
            event: version.event,
            whodunnit: version.whodunnit,
            ip: '217.54.108.228',
            object: {
              'name' => 'Don Corleone',
            },
            object_changes: {
              'name' => [nil, 'Don Corleone'],
            },
            created_at: version.created_at,
          )
        end
      end

      context 'when fields are explicitly given' do
        let(:fields) do
          [
            { field: :name, method: :anonymize_name },
          ]
        end

        it 'does not anonymize version' do
          version_data_policy.erase(version, fields)
          expect(version.reload).to have_attributes(
            id: version.id,
            item_type: version.item_type,
            item_id: version.item_id,
            event: version.event,
            whodunnit: version.whodunnit,
            ip: '217.54.108.228',
            object: {
              'name' => 'Pei Wunsch',
            },
            object_changes: {
              'name' => [nil, 'Pei Wunsch'],
            },
            created_at: version.created_at,
          )
        end
      end
    end
  end
end
