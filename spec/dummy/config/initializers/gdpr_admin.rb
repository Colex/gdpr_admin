# frozen_string_literal: true

GdprAdmin.configure do |config|
  config.default_job_queue = :gdpr_tasks
end
