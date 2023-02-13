# frozen_string_literal: true

module GdprAdmin
  class Configuration
    attr_accessor :tenant_class, :requester_class
    attr_writer :tenant_adapter

    def initialize
      @tenant_class = 'Organization'
      @requester_class = 'AdminUser'
      @tenant_adapter = GdprAdmin::TenantAdapters::ActsAsTenantAdapter.new
    end

    def tenant_adapter
      return @tenant_adapter unless @tenant_adapter.is_a?(Symbol)

      GdprAdmin::TenantAdapters.const_get("#{@tenant_adapter}_adapter".classify)
    end
  end
end
