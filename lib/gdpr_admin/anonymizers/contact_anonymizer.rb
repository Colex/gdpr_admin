# frozen_string_literal: true

module GdprAdmin
  module Anonymizers
    module ContactAnonymizer
      def anonymize_phone_number
        Faker::PhoneNumber.phone_number
      end

      def anonymize_street_address
        Faker::Address.street_address
      end

      def anonymize_city
        Faker::Address.city
      end

      def anonymize_state
        Faker::Address.state
      end

      def anonymize_zip
        Faker::Address.zip
      end

      def anonymize_country
        Faker::Address.country
      end

      def anonymize_country_code2
        Faker::Address.country_code
      end

      def anonymize_country_code3
        Faker::Address.country_code_long
      end
    end
  end
end
