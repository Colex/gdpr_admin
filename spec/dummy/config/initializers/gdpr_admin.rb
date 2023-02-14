# frozen_string_literal: true

GdprAdmin.configure do |config|
  config.jobs_queue = :gdpr_tasks
end
