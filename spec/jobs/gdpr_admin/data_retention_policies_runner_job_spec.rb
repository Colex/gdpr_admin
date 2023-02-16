# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::DataRetentionPoliciesRunnerJob, type: :job do
  fixtures :organizations

  describe '.perform_later' do
    it 'queues the job in the configured queue' do
      expect { described_class.perform_later }.to have_enqueued_job(described_class)
        .on_queue(GdprAdmin.config.default_job_queue)
    end
  end

  describe '#perform' do
    subject(:job) { described_class.new }

    before do
      GdprAdmin::DataRetentionPolicy.create!(
        tenant: organizations(:beatles),
        active: true,
        period_in_days: 10,
      )

      GdprAdmin::DataRetentionPolicy.create!(
        tenant: organizations(:star_wars),
        active: false,
        period_in_days: 10,
      )
    end

    it 'processes only the active policies' do
      expect { job.perform }.to change(GdprAdmin::Request, :count).by(1)
    end

    it 'creates a request for each active policy' do
      job.perform

      expect(GdprAdmin::Request.last).to have_attributes(
        tenant: organizations(:beatles),
        requester: nil,
        request_type: 'erase_data',
        data_older_than: be_within(5.seconds).of(10.days.ago),
      )
    end

    it 'enqueues a job to process the request in configured queue' do
      expect { job.perform }
        .to have_enqueued_job(GdprAdmin::RequestProcessorJob)
        .with(GdprAdmin::Request.last)
        .on_queue(GdprAdmin.config.default_job_queue)
    end
  end
end
