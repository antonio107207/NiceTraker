FactoryBot.define do
  factory :comment do
    body { "MyText" }
    card { nil }
    user { nil }
  end
end
