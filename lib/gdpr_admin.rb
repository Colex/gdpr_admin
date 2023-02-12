# frozen_string_literal: true

require 'gdpr_admin/version'
require 'gdpr_admin/engine'
require 'gdpr_admin/application_data_policy'
require 'gdpr_admin/tenant_adapters/acts_as_tenant_adapter'

module GdprAdmin
  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end
end
