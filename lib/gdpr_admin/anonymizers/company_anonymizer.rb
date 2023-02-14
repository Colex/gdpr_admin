# frozen_string_literal: true

module GdprAdmin
  module Anonymizers
    module CompanyAnonymizer
      def anonymize_company
        Faker::Company.name
      end
    end
  end
end
