# frozen_string_literal: true

module GdprAdmin
  module DataRetentionPolicyConcern
    extend ActiveSupport::Concern

    included do
      belongs_to :tenant, class_name: GdprAdmin.config.tenant_class

      scope :active, -> { where(active: true) }

      validates :active, inclusion: { in: [true, false] }
      validates :period_in_days, numericality: { only_integer: true, greater_than: 0 }
    end

    def process!
      with_lock do
        raise InvalidStatusError unless active?
        return unless should_process?

        Request.create!(
          tenant: tenant,
          requester: nil,
          request_type: :erase_data,
          data_older_than: period_in_days.days.ago,
        )
        update!(last_run_at: Time.now.utc)
      end
    end

    def should_process?
      true
    end
  end
end
