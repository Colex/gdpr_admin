# frozen_string_literal: true

module GdprAdmin
  module PaperTrail
    class VersionDataPolicy < GdprAdmin::ApplicationDataPolicy
      def scope
        ::PaperTrail::Version.none
      end

      def erase(version, item_fields = nil)
        item_fields ||= infer_item_fields(version)
        return if item_fields.nil?

        base_changes = {
          object: anonymize_version_object(version, item_fields),
          object_changes: anonymize_version_object_changes(version, item_fields),
        }.compact
        erase_fields(version, fields, base_changes)
      end

      def fields
        []
      end

      private

      def infer_item_fields(version)
        infer_data_policy_class(version)&.new(request)&.try(:fields)
      end

      def infer_data_policy_class(version)
        model = version.item_type.constantize.new
        return model.data_policy_class if model.respond_to?(:data_policy_class)

        prefix = model.data_policy_prefix if model.respond_to?(:data_policy_prefix)
        "#{prefix}#{version.item_type}DataPolicy".constantize
      rescue NameError
        nil
      end
    end
  end
end
