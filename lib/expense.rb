class Expense
  attr_accessor :amount, :categories, :payment_methods, :date, :description, :user

  def initialize(amount, categories, payment_methods, date, description, user)
    @amount = amount.to_f
    @categories = categories
    @payment_methods = payment_methods
    @date = date
    @description = description
    @user = user
  end

  def to_h(with_associations: false)
    hash = {
      amount: @amount,
      date: @date,
      description: @description
    }
    
    if with_associations
      hash[:user] = { name: @user.name }
      hash[:categories] = @categories.map { |c| { name: c.name } }
      hash[:payment_methods] = @payment_methods.map { |pm| { name: pm.name } }
    end
    
    hash
  end

  def self.from_h(hash)
    new(
      hash[:amount],
      hash[:categories],
      hash[:payment_methods],
      hash[:date],
      hash[:description],
      hash[:user]
    )
  end

  def to_s
    "[#{@date}] #{@description} - #{@amount}₴"
  end

  def details
    "   Категорії: #{@categories.join(', ')}\n   Способи оплати: #{@payment_methods.join(', ')}\n   Здійснив витрату: #{@user}"
  end
end