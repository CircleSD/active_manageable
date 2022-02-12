FactoryBot.define do
  factory :user do
    name { "John Smith" }
    sequence(:email) { |n| "user#{n}@rspec.org" }
    locale { "en-GB" }
    time_zone { "London" }
  end
end
