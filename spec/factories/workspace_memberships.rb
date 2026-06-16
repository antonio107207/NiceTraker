FactoryBot.define do
  factory :workspace_membership do
    workspace { nil }
    user { nil }
    role { 1 }
  end
end
