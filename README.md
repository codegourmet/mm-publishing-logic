# mm-publishing-logic

Publishing Logic for Rails/MongoMapper models

## Installation

Add this line to your application's Gemfile:

    gem 'mm-publishing-logic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mm-publishing-logic

## Usage

Just include it in your models:

    class Page
      include MongoMapper::Document
      plugin MongoMapper::Plugins::PublishingLogic

      key :title, String
    end

This will add some keys, methods and scopes.

### Keys

#### `:published_flag`
If this is set to false (default), the record will always count as unpublished.

#### `:publishing_date`
The record will count as published as soon as the current date is greater or equal than this key's value.
NOTE: the record will still be unpublished if `published_flag` is false.

#### `:publishing_end_date`
If the current date is greater than this key's value, the record will be considered unpublished.

### Scopes

#### `published`
Returns all records that are considered published concerning their persisted state.

#### `unpublished`
Returns all records that are considered unpublished concerning their persisted state.

### Methods

#### `published?`
Will return the current state.
NOTE: this will query the current in-memory object's state, not the database state. Changes to any of the publishing logic attributes will be reflected.

### Module methods
You can deactivate the publishing logic entirely for a block by using the `deactivated` method:

    MongoMapper::Plugins::PublishingLogic.deactivated do
      published = Page.published # will always return all Page record
      unpublished = Page.unpublished # will always return an empty query
    end

Also, you can switch a block with a boolean variable:

    is_activated = false
    MongoMapper::Plugins::PublishingLogic.with_status(is_activated) do
      # publishing logic will be active/deactive depending on the with_status() param
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
