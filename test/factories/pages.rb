FactoryGirl.define do
  factory :page do
    sequence(:title) {|n| "title_#{n}"}
    published_flag true
    publishing_date {TODAY - 1.days}
  end
end
