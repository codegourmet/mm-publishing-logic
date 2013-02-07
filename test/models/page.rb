require "mongo_mapper"
require "mm-publishing-logic"

class Page
  include MongoMapper::Document
  include MongoMapper::Plugins::PublishingLogic

  key :title, String
end
