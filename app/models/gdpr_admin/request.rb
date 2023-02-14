# frozen_string_literal: true

module GdprAdmin
  class Request < ApplicationRecord
    belongs_to :tenant, class_name: GdprAdmin.config.tenant_class
    belongs_to :requester, class_name: GdprAdmin.config.requester_class

    enum status: {
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed',
    }

    enum request_type: {
      subject_export: 'subject_export',
      erase_all: 'erase_all',
      erase_subject: 'erase_subject',
      erase_timeframe: 'erase_timeframe',
    }

    before_validation :set_default_data_older_than!
    after_create_commit :schedule_processing

    def process!
      GdprAdmin.load_data_policies
      with_lock { processing! }
      with_lock do
        GdprAdmin.config.tenant_adapter.with_tenant(tenant) { process_policies }
        completed!
      end
    rescue StandardError
      failed!
      raise
    end

    def erase?
      erase_all? || erase_subject? || erase_timeframe?
    end

    def export?
      subject_export?
    end

    def schedule_processing
      RequestProcessorJob.set(wait: grace_period).perform_later(self)
    end

    private

    def grace_period
      export? ? GdprAdmin.config.export_grace_period : GdprAdmin.config.erasure_grace_period
    end

    def process_policies
      ApplicationDataPolicy.descendants.each do |policy_class|
        policy = policy_class.new(self)
        policy.scope.find_each do |record|
          policy.export(record) if export?
          policy.erase(record) if erase?
        end
      rescue SkipDataPolicyError
        next
      end
    end

    def set_default_data_older_than!
      self.data_older_than ||= Time.zone.now
    end
  end
end
