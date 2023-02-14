# frozen_string_literal: true

require_relative '../anonymizers/name_anonymizer'
require_relative '../anonymizers/contact_anonymizer'
require_relative '../anonymizers/internet_anonymizer'

module GdprAdmin
  module Helpers
    module EraseHelper
      include Anonymizers::NameAnonymizer
      include Anonymizers::ContactAnonymizer
      include Anonymizers::InternetAnonymizer

      ##
      # Erases the given fields on the given record using the method given.
      # Fields should be an array of hashes formatted as follows:
      #
      # ```ruby
      #   [
      #     { field: :first_name, method: :anonymize, seed: :id },
      #     { field: :last_name, method: :anonymize },
      #     { field: :job_title, method: -> { 'Anonymized Title' } },
      #     { field: :email, method: :anonymize_email },
      #     { field: :password_digest, method: :anonymize_password },
      #     { field: :phone_number, method: ->(record) { record.phone_number.split('').shuffle.join } },
      #     { field: :address, method: :nillify },
      #   ]
      # ```
      #
      # By default, the seed for the anonymize method is the value of the field being anonymized.
      # If you want to use a different field as the seed, you can specify it using the `seed` key.
      #
      # If you want to use a method that is not defined in the anonymizer, you can pass a lambda.
      # The lambda will be called with the record as the first argument and the seed as the second.
      #
      # The third argument of the `erase_fields` method is an optional base fields hash that will be used to
      # update the record. This is useful if you want to `erase_fields` to update other fields that
      # are not part of the erasure process. For example:
      #
      # ```ruby
      #   erase_fields(record, fields, { anonymized_at: Time.zone.now })
      # ```
      #
      # This method uses the `update_columns` method to update the record, so it will skip validations.
      #
      # @param record [ActiveRecord::Base] The record to erase
      # @param fields [Array<Hash>] The fields to erase
      # @param base_fields [Hash] The fields to update on the record together with the erased fields
      def erase_fields(record, fields, base_fields = {})
        new_data = fields.inject(base_fields) do |res, curr|
          next res if record[curr[:field]].nil?

          res.merge(
            curr[:field] => call_method(curr[:method], record, record[curr[:seed] || curr[:field]]),
          )
        end
        record.update_columns(new_data)
      end

      def nillify
        nil
      end

      def with_seed(seed)
        Faker::Config.random = Random.new(seed.to_s.chars.sum(&:ord)) if defined?(Faker)
        yield
      end

      private

      def call_method(erase_method, record, seed)
        return if erase_method.nil?

        erase_method = method(erase_method) if erase_method.is_a?(Symbol)

        arity = erase_method.arity
        with_seed(seed) do
          erase_method.call(*[record, seed].take(arity))
        end
      end
    end
  end
end
