# frozen_string_literal: true

module GdprAdmin
  class Configuration
    attr_accessor :tenant_class, :data_policies_path, :default_job_queue,
                  :erasure_grace_period, :export_grace_period, :rollback_on_failure
    attr_writer :tenant_adapter

    def initialize
      @tenant_class = 'Organization'
      @tenant_adapter = TenantAdapters::ActsAsTenantAdapter.new
      @data_policies_path = Rails.root.join('app', 'gdpr')
      @default_job_queue = :default
      @erasure_grace_period = 4.hours
      @export_grace_period = nil
      @rollback_on_failure = true
    end

    def tenant_adapter
      return @tenant_adapter unless @tenant_adapter.is_a?(Symbol)

      GdprAdmin::TenantAdapters.const_get("#{@tenant_adapter}_adapter".classify).new
    end
  end
end
