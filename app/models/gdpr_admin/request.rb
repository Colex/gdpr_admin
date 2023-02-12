# frozen_string_literal: true

module GdprAdmin
  class Request < ApplicationRecord
    belongs_to :tenant, class_name: 'Organization'
    belongs_to :requester, class_name: 'AdminUser'

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

    after_create_commit :schedule_processing

    def process!
      with_lock { processing! }
      with_lock do
        GdprAdmin.configuration.tenant_adapter.with_tenant(tenant) do
          process_policies
        end
        completed!
      end
    rescue StandardError
      failed!
    end

    def erase?
      erase_all? || erase_subject? || erase_timeframe?
    end

    def export?
      subject_export?
    end

    def schedule_processing
      TaskRunnerJob.set(wait: 4.hours).perform_later(self)
    end

    private

    def process_policies
      ApplicationDataPolicy.descendants.each do |policy_class|
        policy = policy_class.new(self)
        policy.scope.find_each do |record|
          policy.export(record) if export?
          policy.erase(record) if erase?
        end
      end
    end
  end
end