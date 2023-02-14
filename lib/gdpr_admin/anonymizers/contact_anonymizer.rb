# frozen_string_literal: true

module GdprAdmin
  module Anonymizers
    module ContactAnonymizer
      def anonymize_phone_number
        Faker::PhoneNumber.phone_number
      end
    end
  end
end
