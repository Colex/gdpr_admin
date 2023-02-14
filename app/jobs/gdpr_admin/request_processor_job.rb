# frozen_string_literal: true

module GdprAdmin
  class RequestProcessorJob < ApplicationJob
    queue_as GdprAdmin.config.jobs_queue

    def perform(task)
      task.process!
    end
  end
end
