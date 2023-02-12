# frozen_string_literal: true

module GdprAdmin
  class TaskRunnerJob < ActiveJob::Base
    def perform(task)
      task.process!
    end
  end
end
