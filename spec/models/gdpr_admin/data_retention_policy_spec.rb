# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::DataRetentionPolicy, type: :model do
  fixtures :organizations

  describe '#process!' do
    subject(:request) do
      data_retention_policy_class.create!(
        tenant: tenant,
        active: active,
        period_in_days: period_in_days,
      )
    end

    let(:data_retention_policy_class) { described_class }
    let(:tenant) { organizations(:beatles) }
    let(:period_in_days) { 45 }

    context 'when the policy is active' do
      let(:active) { true }

      it 'creates a request to erase tenant data' do
        request.process!
        expect(GdprAdmin::Request.last).to have_attributes(
          tenant: tenant,
          requester: nil,
          request_type: 'erase_data',
          data_older_than: be_within(5.seconds).of(45.days.ago),
        )
      end

      it 'creates a single request' do
        expect { request.process! }.to change(GdprAdmin::Request, :count).by(1)
      end

      it 'updates the last run time' do
        expect { request.process! }.to change(request, :last_run_at)
          .from(nil).to(be_within(5.seconds).of(Time.now.utc))
      end

      context 'when policy should not be processed' do
        let(:data_retention_policy_class) do
          Class.new(described_class) do
            def should_process?
              false
            end
          end
        end

        it 'does not create a request' do
          expect { request.process! }
            .to not_change(GdprAdmin::Request, :count)
        end

        it 'does not update the last run time' do
          expect { request.process! }
            .to not_change(request, :last_run_at)
        end
      end
    end

    context 'when the policy is inactive' do
      let(:active) { false }

      it 'raises a InvalidStatusError' do
        expect { request.process! }
          .to raise_error(GdprAdmin::InvalidStatusError)
      end

      it 'does not create a request' do
        expect { request.process! }
          .to raise_error(StandardError)
          .and not_change(GdprAdmin::Request, :count)
      end

      it 'does not update the last run time' do
        expect { request.process! }
          .to raise_error(StandardError)
          .and not_change(request, :last_run_at)
      end
    end
  end
end
