class ExpenseCategory < ApplicationRecord
  # Зв'язки
  belongs_to :expense
  belongs_to :category

  # Валідації
  validates :expense_id, uniqueness: { scope: :category_id }
end