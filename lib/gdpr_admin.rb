# frozen_string_literal: true

require 'gdpr_admin/version'
require 'gdpr_admin/engine'
require 'gdpr_admin/configuration'
require 'gdpr_admin/skip_data_policy_error'
require 'gdpr_admin/helpers/erase_helper'
require 'gdpr_admin/application_data_policy'
require 'gdpr_admin/tenant_adapters/acts_as_tenant_adapter'

begin
  require 'faker'
rescue LoadError; end # rubocop:disable Lint/SuppressedException

module GdprAdmin
  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.load_data_policies(force: false)
    return if Rails.application.config.eager_load && !force

    Dir.glob(Pathname.new(config.data_policies_path).join('**', '*.rb')).each do |file|
      require_dependency file
    end
  end
end
