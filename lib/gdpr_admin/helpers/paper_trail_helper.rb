# frozen_string_literal: true

require_relative './field_anonymizer_helper'

module GdprAdmin
  module Helpers
    module PaperTrailHelper
      include FieldAnonymizerHelper

      def without_paper_trail
        return yield unless defined?(::PaperTrail)

        begin
          current_status = ::PaperTrail.enabled?
          ::PaperTrail.enabled = false
          yield
        ensure
          ::PaperTrail.enabled = current_status
        end
      end

      def anonymize_version_object(version, fields)
        object = version.object.deep_dup
        return object if object.blank?
        return {} if object.is_a?(Array)

        fields.each do |field|
          field_name = field[:field].to_s
          field_value = object[field_name]
          next if field_value.nil?

          new_value = anonymize_field(version.item, field)
          object.merge!(field_name => new_value)
        end
        object
      end

      def anonymize_version_object_changes(version, fields)
        return unless version.respond_to?(:object_changes)

        object_changes = version.object_changes.deep_dup
        return object_changes if object_changes.blank?
        return {} if object_changes.is_a?(Array)

        fields.each do |field|
          field_name = field[:field].to_s
          changes = object_changes[field_name]
          next if changes.nil?

          new_value = anonymize_object_changes_array(version, changes, field)
          object_changes.merge!(field_name => new_value)
        end
        object_changes
      end

      private

      def anonymize_object_changes_array(version, changes, field)
        changes.map do |value|
          anonymize_field_value(version.item, field.merge(seed: value))
        end
      end
    end
  end
end
