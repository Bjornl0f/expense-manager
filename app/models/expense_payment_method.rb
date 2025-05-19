class ExpensePaymentMethod < ApplicationRecord
  # Зв'язки
  belongs_to :expense
  belongs_to :payment_method

  # Валідації
  validates :expense, uniqueness: { scope: :payment_method }
end