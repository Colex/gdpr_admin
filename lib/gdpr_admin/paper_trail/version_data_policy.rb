# frozen_string_literal: true

module GdprAdmin
  module PaperTrail
    class VersionDataPolicy < GdprAdmin::ApplicationDataPolicy
      def scope
        ::PaperTrail::Version.none
      end

      def erase(version, item_fields = nil)
        item_fields ||= infer_item_fields(version)
        erase_fields(version, fields, base_changes(version, item_fields))
      end

      def fields
        []
      end

      private

      def base_changes(version, item_fields)
        return {} if item_fields.blank?

        {
          object: anonymize_version_object(version, item_fields),
          object_changes: anonymize_version_object_changes(version, item_fields),
        }.compact
      end

      def infer_item_fields(version)
        infer_data_policy_class(version)&.new(request)&.try(:fields)
      end

      def infer_data_policy_class(version)
        model_data_policy_class(version.item_type)
      end
    end
  end
end
