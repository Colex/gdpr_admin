# frozen_string_literal: true

module GdprAdmin
  module Helpers
    module DataPolicyHelper
      def skip_data_policy!
        raise SkipDataPolicyError
      end

      def skip_record!
        raise SkipRecordError
      end
    end
  end
end
