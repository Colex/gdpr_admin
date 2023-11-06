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

      def anonymize_ip
        Faker::Internet.ip_v4_address
      end

      def mask_ip(_record, _field, value)
        addr = IPAddr.new(value.to_s)
        return addr.mask(24).to_s if addr.ipv4?

        addr.mask(48).to_s
      rescue IPAddr::InvalidAddressError
        value
      end
    end
  end
end
