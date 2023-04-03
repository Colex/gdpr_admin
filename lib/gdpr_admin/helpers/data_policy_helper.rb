# frozen_string_literal: true

module GdprAdmin
  module Helpers
    module DataPolicyHelper
      def skip_data_policy!
        raise SkipDataPolicyError
      end

      def skip_record!
        raise SkipRecordError
      end

      def model_data_policy_class(model)
        model = model.constantize if model.is_a?(String)
        return model.data_policy_class if model.respond_to?(:data_policy_class)

        prefix = model.data_policy_prefix if model.respond_to?(:data_policy_prefix)
        "#{prefix}#{model}DataPolicy".constantize
      rescue NameError
        nil
      end
    end
  end
end
