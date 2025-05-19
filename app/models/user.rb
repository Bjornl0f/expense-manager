class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # Зв'язки з моделями витрат
  has_many :expenses, dependent: :destroy
  has_many :spenders, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :payment_methods, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
end