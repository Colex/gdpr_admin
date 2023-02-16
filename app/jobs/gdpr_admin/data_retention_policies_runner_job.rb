# frozen_string_literal: true

module GdprAdmin
  class DataRetentionPoliciesRunnerJob < ApplicationJob
    queue_as GdprAdmin.config.default_job_queue

    def perform
      GdprAdmin::DataRetentionPolicy.active.find_each(&:process!)
    end
  end
end
