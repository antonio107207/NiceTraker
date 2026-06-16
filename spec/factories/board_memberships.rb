FactoryBot.define do
  factory :board_membership do
    board { nil }
    user { nil }
    role { 1 }
  end
end
