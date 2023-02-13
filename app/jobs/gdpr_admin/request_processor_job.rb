# frozen_string_literal: true

module GdprAdmin
  class RequestProcessorJob < ActiveJob::Base
    def perform(task)
      task.process!
    end
  end
end
