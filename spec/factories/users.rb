FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "redjourney #{n}" }
    name { 'redjourney2016' }
    url { 'http://example.com' }
    avatar_url { 'http://example.com/avatar' }
    provider { 'github' }
  end
end
