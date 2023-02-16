# frozen_string_literal: true

module GdprAdmin
  module Helpers
    module ScopeHelper
      def scope_by_date(scope, field = :updated_at)
        scope.where(field => ...request.data_older_than)
      end
    end
  end
end
