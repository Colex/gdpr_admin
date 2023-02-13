require 'active_record/fixtures'

fixtures_dir = Rails.root.join('db', 'fixtures')

fixtures = Dir["#{fixtures_dir}/**/*.yml"].map do |file|
  File.basename(file, '.yml')
end

ActiveRecord::FixtureSet.create_fixtures(fixtures_dir, fixtures)
