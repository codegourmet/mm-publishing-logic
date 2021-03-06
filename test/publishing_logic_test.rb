# encoding: UTF-8

require 'test_helper'
require 'timecop'

class PublishingLogicTest < ActiveSupport::TestCase

  setup do
    Page.delete_all
  end


  test "should define keys" do
    [:published_flag, :publishing_date, :publishing_end_date].each do |key|
      assert Page.keys.keys.include?(key.to_s), "should define key #{key}"
    end
  end


  test "published flag" do
    assert_equal false, Page.new.published_flag, "should default to unpublished"

    published = FactoryGirl.create(:page, published_flag: true, publishing_date: nil)
    assert_equal [published], Page.published.all
    assert published.published?

    unpublished = FactoryGirl.create(:page, published_flag: false, publishing_date: nil)
    assert !unpublished.published?
    assert_equal [unpublished], Page.unpublished.all
  end


  test "publishing_date" do
    published = [
      FactoryGirl.create(:page, publishing_date: TODAY),
      FactoryGirl.create(:page, publishing_date: PAST)
    ]
    assert_published(published)

    unpublished = [FactoryGirl.create(:page, publishing_date: FUTURE)]
    assert_unpublished(unpublished)
  end


  test "publishing_end_date" do
    published = [
      FactoryGirl.create(:page, publishing_end_date: FUTURE),
      FactoryGirl.create(:page, publishing_end_date: TODAY)
    ]
    assert_published(published)

    unpublished = [
      FactoryGirl.create(:page, publishing_end_date: PAST)
    ]
    assert_unpublished(unpublished)
  end


  test "publishing_end_date holds when date changes" do
    soon_unpublished = [
      FactoryGirl.create(:page, publishing_date: nil, publishing_end_date: TODAY)
    ]
    assert_published(soon_unpublished)

    Timecop.travel(FUTURE)
    assert_unpublished(soon_unpublished)

    Timecop.return
    assert_published(soon_unpublished)
  end


  test "publishing logic deactivation" do
    Page.delete_all
    published = [FactoryGirl.create(:page, published_flag: true)]
    unpublished = [FactoryGirl.create(:page, published_flag: false)]
    all = published + unpublished

    MongoMapper::Plugins::PublishingLogic.deactivated do
      assert_equal all, Page.published.all, "publishing logic should deactivate"
      assert_equal [], Page.unpublished.all, "publishing logic should deactivate"
    end

    MongoMapper::Plugins::PublishingLogic.with_status(false) do
      assert_equal all, Page.published.all, "publishing logic should deactivate"
      assert_equal [], Page.unpublished.all, "publishing logic should deactivate"
    end
  end


protected

  def cur_date
    "(Date: #{Time.now.to_date})"
  end


  def assert_published(expected_records)
    expected_records.each {|record| assert(record.published?, "record should be published #{cur_date}")}
    assert_equal expected_records, Page.published.all, "published scope records should match #{cur_date}"
  end


  def assert_unpublished(expected_records)
    expected_records.each {|record| assert(!record.published?, "record should be unpublished #{cur_date}")}
    assert_equal expected_records, Page.unpublished.all, "unpublished scope records should match #{cur_date})"
  end

end
