# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

# mongomapper doesn't have transactions, so testing db will
# accumulate data (and tests might fail on second run)
module MongoMapperTestingFix
  # Drop all columns after each test case.
  def teardown
    MongoMapper.database.collections.each do |coll|
      coll.remove
    end
  end


  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method teardown do
      super
    end
  end
end

class ActiveSupport::TestCase
  include MongoMapperTestingFix
end
