FactoryBot.define do
  factory :activity do
    trackable { nil }
    owner { nil }
    key { "MyString" }
    parameters { "" }
    board { nil }
  end
end
