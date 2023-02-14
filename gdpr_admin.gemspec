# frozen_string_literal: true

require_relative 'lib/gdpr_admin/version'

Gem::Specification.new do |spec|
  spec.name        = 'gdpr_admin'
  spec.version     = GdprAdmin::VERSION
  spec.authors     = ['Colex']
  spec.email       = ['alex.santos@reachdesk.com']
  spec.homepage    = 'https://github.com/Colex/gdpr_admin'
  spec.summary     = 'Engine for managing GDPR processes.'
  spec.description = 'Engine for managing GDPR processes.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Colex/gdpr_admin'
  spec.metadata['changelog_uri'] = 'https://github.com/Colex/gdpr_admin'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.required_ruby_version = '>= 2.7.4'

  spec.add_dependency 'rails', '>= 6.1.7'

  spec.add_development_dependency 'rspec-rails', '~> 6.0.1'
  spec.add_development_dependency 'rubocop', '~> 1.45.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.11.5'
  spec.add_development_dependency 'rubocop-rails', '~> 2.12.4'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4.0'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
  spec.add_development_dependency 'timecop', '~> 0.9.6'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
