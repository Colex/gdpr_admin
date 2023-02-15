# frozen_string_literal: true

require_relative '../anonymizers/name_anonymizer'
require_relative '../anonymizers/company_anonymizer'
require_relative '../anonymizers/contact_anonymizer'
require_relative '../anonymizers/internet_anonymizer'

module GdprAdmin
  module Helpers
    module FieldAnonymizerHelper
      include Anonymizers::NameAnonymizer
      include Anonymizers::CompanyAnonymizer
      include Anonymizers::ContactAnonymizer
      include Anonymizers::InternetAnonymizer

      def anonymize_field(record, field)
        field_name = field[:field]
        value = record[field_name]
        return value if value.nil?

        seed = record[field[:seed] || field_name]
        anonymize_field_value(record, field.merge(seed: seed))
      end

      def nilify
        nil
      end

      def nullify
        nil
      end

      def with_seed(seed)
        Faker::Config.random = Random.new(seed.to_s.chars.sum(&:ord)) if defined?(Faker)
        yield
      end

      private

      def anonymize_field_value(record, field)
        return field[:seed] if field[:seed].blank?

        call_method(field[:method], record, field[:field], field[:seed])
      end

      def call_method(erase_method, record, field, seed)
        raise ArgumentError, "Erase method is not defined for #{field}" if erase_method.nil?
        return seed if erase_method == :skip

        erase_method = method(erase_method) if erase_method.is_a?(Symbol)

        arity = erase_method.arity
        with_seed(seed) do
          erase_method.call(*[record, field, seed].take(arity))
        end
      end
    end
  end
end
