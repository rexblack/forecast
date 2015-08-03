require 'spec_helper'
RSpec.configure do |config|
  
  config.global_fixtures = :all
  config.fixture_path = "fixtures"
  
  config.before(:suite) do
    puts 'before suite'
  end
  
  # after each spec with js, turn transactional fixtures back on
  # rebuild fixtures
  config.after(:each, js: true) do
    puts 'after'
  end
end