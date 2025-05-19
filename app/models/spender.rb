class Spender < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy
  
  validates :name, presence: true, uniqueness: { scope: :user_id }, length: { minimum: 2, maximum: 50 }
end
