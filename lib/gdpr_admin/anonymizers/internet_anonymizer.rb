# frozen_string_literal: true

module GdprAdmin
  module Anonymizers
    module InternetAnonymizer
      def anonymize_email
        Faker::Internet.email
      end

      def anonymize_password(record)
        record.send(:password_digest, SecureRandom.hex(32))
      end
    end
  end
end
