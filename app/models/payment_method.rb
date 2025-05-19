class PaymentMethod < ApplicationRecord
  # Зв'язки
  belongs_to :user
  has_many :expense_payment_methods, dependent: :destroy
  has_many :expenses, through: :expense_payment_methods

  # Валідації
  validates :name, presence: true, 
    uniqueness: { scope: :user_id }, 
    length: { minimum: 2, maximum: 50 }
end
