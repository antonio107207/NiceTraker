FactoryBot.define do
  factory :card do
    title { "MyString" }
    description { "MyText" }
    position { 1 }
    due_date { "2026-06-16 15:02:05" }
    due_completed { false }
    cover_color { "MyString" }
    list { nil }
    board { nil }
    archived_at { "2026-06-16 15:02:05" }
  end
end
