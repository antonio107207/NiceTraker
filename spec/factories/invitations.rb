FactoryBot.define do
  factory :invitation do
    board { nil }
    inviter { nil }
    email { "MyString" }
    token { "MyString" }
    role { 1 }
    status { 1 }
    expires_at { "2026-06-16 15:01:48" }
  end
end
