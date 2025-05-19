class ExpenseCategory < ApplicationRecord
  #Зв'язки
  belongs_to :expense
  belongs_to :category

  #Валідації
  validates :expense, uniqueness: { scope: :category }
end