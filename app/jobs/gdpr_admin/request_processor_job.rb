# frozen_string_literal: true

module GdprAdmin
  class RequestProcessorJob < ApplicationJob
    def perform(task)
      task.process!
    end
  end
end
