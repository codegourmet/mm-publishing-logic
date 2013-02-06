# encoding: UTF-8

require 'test_helper'

TODAY = ActiveSupport::TimeZone["UTC"].now.beginning_of_day.to_date
PAST = TODAY - 2.days
FUTURE = TODAY + 2.days


class PublishingTestModel
  include MongoMapper::Document
  include MongoMapper::Plugins::PublishingLogic

  key :title, String
end


FactoryGirl.define do
  factory :publishing_test_model do
    sequence(:title) {|n| "title_#{n}"}
    published_flag true
    publishing_date {TODAY - 1.days}
  end
end


class PublishingLogicTest < ActiveSupport::TestCase

  setup do
    PublishingTestModel.delete_all
  end


  test "should define keys" do
    [:published_flag, :publishing_date, :publishing_end_date, :published_state].each do |key|
      assert PublishingTestModel.keys.keys.include?(key.to_s), "should define key #{key}"
    end
  end


  test "published flag" do
    assert_equal false, PublishingTestModel.new.published_flag, "should default to unpublished"

    published = FactoryGirl.create(:publishing_test_model, published_flag: true)
    assert_equal [published], PublishingTestModel.published.all
    assert published.published?

    unpublished = FactoryGirl.create(:publishing_test_model, published_flag: false)
    assert !unpublished.published?
    assert_equal [unpublished], PublishingTestModel.unpublished.all
  end


  test "publishing_date" do
    published = [
      FactoryGirl.create(:publishing_test_model, publishing_date: TODAY),
      FactoryGirl.create(:publishing_test_model, publishing_date: PAST)
    ]
    assert_published(published)

    unpublished = [FactoryGirl.create(:publishing_test_model, publishing_date: FUTURE)]
    assert_unpublished(unpublished)
  end


  test "publishing_end_date" do
    published = [
      FactoryGirl.create(:publishing_test_model, publishing_end_date: TODAY),
      FactoryGirl.create(:publishing_test_model, publishing_end_date: FUTURE)
    ]
    assert_published(published)

    unpublished = [FactoryGirl.create(:publishing_test_model, publishing_end_date: PAST)]
    assert_unpublished(unpublished)
  end


  test "publishing logic deactivation" do
    PublishingTestModel.delete_all
    published = [FactoryGirl.create(:publishing_test_model, published_flag: true)]
    unpublished = [FactoryGirl.create(:publishing_test_model, published_flag: false)]
    all = published + unpublished

    MongoMapper::Plugins::PublishingLogic.deactivated do
      assert_equal all, PublishingTestModel.published.all, "publishing logic should deactivate"
      assert_equal [], PublishingTestModel.unpublished.all, "publishing logic should deactivate"
    end

    MongoMapper::Plugins::PublishingLogic.with_status(false) do
      assert_equal all, PublishingTestModel.published.all, "publishing logic should deactivate"
      assert_equal [], PublishingTestModel.unpublished.all, "publishing logic should deactivate"
    end
  end


protected


  def assert_published(expected_records)
    expected_records.each {|record| assert(record.published?, "record should be published")}
    assert_equal expected_records, PublishingTestModel.published.all, "published scope records should match"
  end


  def assert_unpublished(expected_records)
    expected_records.each {|record| assert(!record.published?, "record should be unpublished")}
    assert_equal expected_records, PublishingTestModel.unpublished.all, "unpublished scope records should match"
  end

end
