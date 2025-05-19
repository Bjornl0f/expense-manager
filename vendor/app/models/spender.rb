class Spender < ApplicationRecord
  has_many :expenses, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
end
