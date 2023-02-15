# frozen_string_literal: true

module GdprAdmin
  module Helpers
    module PaperTrailHelper
      def without_paper_trail
        return yield unless defined?(PaperTrail)

        begin
          current_status = PaperTrail.enabled?
          PaperTrail.enabled = false
          yield
        ensure
          PaperTrail.enabled = current_status
        end
      end
    end
  end
end
