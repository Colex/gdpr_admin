# frozen_string_literal: true

module GdprAdmin
  module Anonymizers
    module NameAnonymizer
      def anonymize_name
        Faker::Name.name
      end

      def anonymize_first_name
        Faker::Name.first_name
      end

      def anonymize_last_name
        Faker::Name.last_name
      end
    end
  end
end
