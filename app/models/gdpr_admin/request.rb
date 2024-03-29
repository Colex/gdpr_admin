# frozen_string_literal: true

module GdprAdmin
  class Request < ApplicationRecord
    belongs_to :tenant, class_name: GdprAdmin.config.tenant_class
    belongs_to :requester, polymorphic: true, optional: true

    VALID_STATUS_TRANSITIONS = {
      pending: %i[processing canceled],
      processing: %i[completed failed],
      completed: [],
      failed: %i[pending],
      canceled: %i[],
    }.freeze

    enum status: {
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed',
      canceled: 'canceled',
    }

    enum request_type: {
      export_subject: 'export_subject',
      erase_data: 'erase_data',
      erase_subject: 'erase_subject',
    }

    before_validation :set_default_data_older_than!
    after_create_commit :schedule_processing

    validates :status, presence: true
    validates :subject, presence: true, if: :subject_request?
    validates :subject, absence: true, unless: :subject_request?
    validate :valid_status_transition?

    def cancel!
      canceled!
    end

    def process!
      GdprAdmin.load_data_policies
      reload.lock_strategy { processing! }
      lock_strategy do
        process_policies
        completed!
      end
    rescue StandardError
      failed!
      raise
    end

    def subject_request?
      export_subject? || erase_subject?
    end

    def erase?
      erase_data? || erase_subject?
    end

    def export?
      export_subject?
    end

    def schedule_processing
      RequestProcessorJob.set(wait: grace_period).perform_later(self)
    end

    def lock_strategy(&block)
      return with_lock(&block) if GdprAdmin.config.rollback_on_failure
      return with_advisory_lock(to_global_id.to_s, &block) if respond_to?(:with_advisory_lock)

      yield
    end

    private

    def grace_period
      export? ? GdprAdmin.config.export_grace_period : GdprAdmin.config.erasure_grace_period
    end

    def process_policies
      ApplicationDataPolicy.descendants.each do |policy_class|
        policy_class.process(self)
      end
    end

    def set_default_data_older_than!
      self.data_older_than ||= Time.zone.now
    end

    def valid_status_transition?
      return true if status_was.nil? || status.nil? || status_was == status
      return true if VALID_STATUS_TRANSITIONS[status_was.to_sym].include?(status.to_sym)

      errors.add(:status, :invalid_transition)
      false
    end
  end
end
