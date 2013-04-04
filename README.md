# [![Coverage Status](https://coveralls.io/repos/codegourmet/mm-publishing-logic/badge.png?branch=master)](https://coveralls.io/r/codegourmet/mm-publishing-logic) mm-publishing-logic


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

This attribute defaults to `false`.

    p = Page.new(title: 'published', published_flag: true, publishing_date: Time.now.to_date)
    p.published? # => true

    p = Page.new(title: 'unpublished', published_flag: false, publishing_date: Time.now.to_date)
    p.published? # => false

#### `:publishing_date`
The record will count as published as soon as the current date is greater or equal than this key's value.

This attribute defaults to `ActiveSupport::TimeZone["UTC"].now.beginning_of_day.to_date`.

NOTE: the record will still be considered unpublished if `published_flag` is false.

    p = Page.new(title: 'published', published_flag: true, publishing_date: Time.now.to_date)
    p.published? # => true

    p = Page.new(title: 'unpublished', published_flag: true, publishing_date: Time.now.to_date + 1.days)
    p.published? # => false

#### `:publishing_end_date`
If the current date is greater than this key's value, the record will be considered unpublished.

NOTE: This attribute is optional.

    p = Page.new(
        title: 'published', published_flag: true,
        publishing_date: Time.now.to_date, publishing_end_date: Time.now + 1.days
    )
    p.published? # => true

    p = Page.new(
        title: 'published', published_flag: true,
        publishing_date: Time.now.to_date, publishing_end_date: Time.now - 1.days
    )
    p.published? # => false

### Scopes

#### `published`
Returns all records that are considered published concerning their persisted state.

    Page.create(title: 'published', published_flag: true, publishing_date: Time.now.to_date)
    Page.create(title: 'unpublished', published_flag: false, publishing_date: Time.now.to_date)
    Page.published.all.map(&:title) # => ['published']

#### `unpublished`
Returns all records that are considered unpublished concerning their persisted state.

    Page.create(title: 'published', published_flag: true, publishing_date: Time.now.to_date)
    Page.create(title: 'unpublished', published_flag: false, publishing_date: Time.now.to_date)
    Page.unpublished.all.map(&:title) # => ['unpublished']

### Methods

#### `published?`
Will return the current state.

NOTE: this will query the current in-memory object's state, not the database state. Changes to any of the publishing logic attributes will be reflected.

### Module methods
You can deactivate the publishing logic entirely for a the current request or for a block by using some module methods:

#### `activate`/`deactivate`
You can use this to manipulate the publishing logic state permanently, for example in your controller if you want to implement an admin preview.

    class ApplicationController < ActionController::Base
      before_filter do
        MongoMapper::Plugins::PublishingLogic.deactivate if (params[:preview] and current_admin)
      end
    end

#### `deactivated`
You can use this to deactivate the publishing logic for the duration of a block:

    MongoMapper::Plugins::PublishingLogic.deactivated do
      published = Page.published # will always return all Page record
      unpublished = Page.unpublished # will always return an empty query
    end

#### `with_status`
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
