class Expense < ApplicationRecord
  # Зв'язки
  belongs_to :user
  has_many :expense_categories, dependent: :destroy
  has_many :categories, through: :expense_categories
  
  has_many :expense_payment_methods, dependent: :destroy
  has_many :payment_methods, through: :expense_payment_methods

  belongs_to :spender

  # Валідації
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :description, presence: true, length: { minimum: 2, maximum: 255 }
  validate :must_have_at_least_one_category
  validate :must_have_at_least_one_payment_method
  validates :spender, presence: true

  private

  def must_have_at_least_one_category
    if categories.empty?
      errors.add(:categories, I18n.t('errors.messages.at_least_one_category'))
    end
  end

  def must_have_at_least_one_payment_method
    if payment_methods.empty?
      errors.add(:payment_methods, I18n.t('errors.messages.at_least_one_payment_method'))
    end
  end
end