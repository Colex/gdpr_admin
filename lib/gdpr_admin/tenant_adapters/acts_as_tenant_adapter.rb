# frozen_string_literal: true

module GdprAdmin
  module TenantAdapters
    class ActsAsTenantAdapter
      def with_tenant(tenant, &block)
        ActsAsTenant.with_tenant(tenant, &block)
      end
    end
  end
end
