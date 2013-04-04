# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# NOTE this has to be at the top!
require 'coveralls'
Coveralls.wear!('rails')

require 'rubygems'
require 'test/unit'
require 'factory_girl'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mongo_mapper'

MongoMapper.database = "mm_publishing_logic-test"

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each {|file| require file}
Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each {|file| require file}

TODAY = ActiveSupport::TimeZone["UTC"].now.beginning_of_day.to_date
PAST = TODAY - 2.days
FUTURE = TODAY + 2.days

# mongomapper doesn't have transactions, so testing db will
# accumulate data (and tests might fail on second run)
module MongoMapperTestingFix
  # Drop all columns after each test case.
  def teardown
    MongoMapper.database.collections.each do |collection|
      collection.drop unless collection.name =~ /(.*\.)?system\..*/
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
