class ExpensePaymentMethod < ApplicationRecord
  # Зв'язки
  belongs_to :expense
  belongs_to :payment_method

  # Валідації
  validates :expense_id, uniqueness: { scope: :payment_method_id }
end