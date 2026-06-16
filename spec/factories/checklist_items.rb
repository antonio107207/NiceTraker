FactoryBot.define do
  factory :checklist_item do
    title { "MyString" }
    position { 1 }
    completed { false }
    checklist { nil }
    assignee { nil }
    due_date { "2026-06-16 15:02:15" }
  end
end
