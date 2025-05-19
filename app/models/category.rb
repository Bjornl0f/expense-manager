class Category < ApplicationRecord
  # Зв'язки
  belongs_to :user
  has_many :expense_categories, dependent: :destroy
  has_many :expenses, through: :expense_categories

  # Валідації
  validates :name, presence: true, 
    uniqueness: { scope: :user_id }, 
    length: { minimum: 2, maximum: 50 }
end