# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::Request, type: :model do
  subject(:request) { described_class.new }

  describe '#erase?' do
    it 'returns true for erase_data?' do
      request.request_type = :erase_data

      expect(request.erase?).to eq(true)
    end

    it 'returns true for erase_subject?' do
      request.request_type = :erase_subject

      expect(request.erase?).to eq(true)
    end

    it 'returns false for export_subject?' do
      request.request_type = :export_subject

      expect(request.erase?).to eq(false)
    end
  end

  describe '#export?' do
    it 'returns true for export_subject?' do
      request.request_type = :export_subject

      expect(request.export?).to eq(true)
    end

    it 'returns false for erase_data?' do
      request.request_type = :erase_data

      expect(request.export?).to eq(false)
    end

    it 'returns false for erase_subject?' do
      request.request_type = :erase_subject

      expect(request.export?).to eq(false)
    end
  end

  describe '#save' do
    context 'when request is new' do
      subject(:request) { described_class.new }

      it 'sets the default data_older_than' do
        request.save
        expect(request.data_older_than).to be_within(1.minute).of(Time.zone.now)
      end

      context 'when request is valid' do
        subject(:request) do
          described_class.new(
            tenant: Organization.create(name: 'Test'),
            requester: AdminUser.create(name: 'Test', email: 'test@admin.com'),
            request_type: request_type,
          )
        end

        context 'when request is an export' do
          let(:request_type) { :export_subject }

          it 'schedules a RequestProcessorJob' do
            GdprAdmin.config.export_grace_period = 1.minute
            Timecop.freeze do
              expect { request.save }.to have_enqueued_job(GdprAdmin::RequestProcessorJob)
                .with(request)
                .on_queue('gdpr_tasks')
                .at(1.minute.from_now)
            end
          end
        end

        context 'when request is an erasure' do
          let(:request_type) { :erase_data }

          it 'schedules a RequestProcessorJob' do
            GdprAdmin.config.erasure_grace_period = 6.hours
            Timecop.freeze do
              expect { request.save }.to have_enqueued_job(GdprAdmin::RequestProcessorJob)
                .with(request)
                .on_queue('gdpr_tasks')
                .at(6.hours.from_now)
            end
          end
        end
      end

      context 'when request is invalid' do
        subject(:request) { described_class.new }

        it 'does not schedule a RequestProcessorJob' do
          expect { request.save }.not_to have_enqueued_job(GdprAdmin::RequestProcessorJob)
        end
      end
    end
  end
end
