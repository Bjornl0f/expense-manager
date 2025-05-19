class PaymentMethod < ApplicationRecord
  # Зв'язки
  has_many :expense_payment_methods, dependent: :destroy
  has_many :expenses, through: :expense_payment_methods

  # Валідації
  validates :name, presence: true, uniqueness: true, 
    length: { minimum: 2, maximum: 50 }
end
