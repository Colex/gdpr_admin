# frozen_string_literal: true

module GdprAdmin
  class Request < ApplicationRecord
    belongs_to :tenant, class_name: GdprAdmin.config.tenant_class
    belongs_to :requester, class_name: GdprAdmin.config.requester_class, optional: true

    VALID_STATUS_TRANSITIONS = {
      pending: %i[processing],
      processing: %i[completed failed],
      completed: [],
      failed: %i[pending],
    }.freeze

    enum status: {
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed',
    }

    enum request_type: {
      export_subject: 'export_subject',
      erase_data: 'erase_data',
      erase_subject: 'erase_subject',
    }

    before_validation :set_default_data_older_than!
    after_create_commit :schedule_processing

    validates :status, presence: true
    validate :valid_status_transition?

    def process!
      GdprAdmin.load_data_policies
      with_lock { processing! }
      with_lock do
        process_policies
        completed!
      end
    rescue StandardError
      with_lock { failed! }
      raise
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
