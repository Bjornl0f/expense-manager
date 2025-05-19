require 'json'
require 'yaml'
require_relative 'expense'
require_relative 'category'
require_relative 'payment_method'
require_relative 'user'

class DataManager
  attr_reader :expenses, :categories, :payment_methods, :users

  def initialize
    @expenses = []
    @categories = []
    @payment_methods = []
    @users = []
  end

  def add_category(name)
    category = Category.new(name.strip)
    return false unless category.valid?
    return false if category_exists?(name)
    
    @categories << category
    true
  end

  def category_exists?(name)
    @categories.any? { |cat| cat.name == name.strip }
  end

  def update_category(index, new_name)
    return false if index < 0 || index >= @categories.size
    return false if new_name.strip.empty?
    return false if @categories.any? { |cat| cat.name == new_name && @categories[index].name != new_name }
    
    old_name = @categories[index].name
    @categories[index].name = new_name
    
    @expenses.each do |expense|
      expense.categories.map! { |cat| cat == old_name ? new_name : cat }
    end
    
    true
  end

  def delete_category(index)
    return false if index < 0 || index >= @categories.size
    
    category_name = @categories[index].name
    
    @expenses.each do |expense|
      expense.categories.delete(category_name)
    end
    
    @categories.delete_at(index)
    true
  end

  def add_payment_method(name)
    payment_method = PaymentMethod.new(name.strip)
    return false unless payment_method.valid?
    return false if payment_method_exists?(name)
    
    @payment_methods << payment_method
    true
  end

  def payment_method_exists?(name)
    @payment_methods.any? { |pm| pm.name == name.strip }
  end

  def update_payment_method(index, new_name)
    return false if index < 0 || index >= @payment_methods.size
    return false if new_name.strip.empty?
    return false if @payment_methods.any? { |pm| pm.name == new_name && @payment_methods[index].name != new_name }
    
    old_name = @payment_methods[index].name
    @payment_methods[index].name = new_name
    
    @expenses.each do |expense|
      expense.payment_methods.map! { |pm| pm == old_name ? new_name : pm }
    end
    
    true
  end

  def delete_payment_method(index)
    return false if index < 0 || index >= @payment_methods.size
    
    payment_method_name = @payment_methods[index].name
    
    @expenses.each do |expense|
      expense.payment_methods.delete(payment_method_name)
    end
    
    @payment_methods.delete_at(index)
    true
  end

  def add_user(name)
    user = User.new(name.strip)
    return false unless user.valid?
    return false if user_exists?(name)

    @users << user
    true
  end

  def user_exists?(name)
    @users.any? { |cat| cat.name == name.strip }
  end

  def update_user(index, new_name)
    return false if index < 0 || index >= @users.size
    return false if new_name.strip.empty?
    return false if @users.any? { |cat| cat.name == new_name && @users[index].name != new_name }
    
    old_name = @users[index].name
    @users[index].name = new_name
    
    @expenses.each do |expense|
      expense.user { |cat| cat == old_name ? new_name : cat }
    end
    
    true
  end

  def delete_user(index)
    return false if index < 0 || index >= @users.size
    
    user_name = @users[index].name
    
    @expenses.each do |expense|
      expense.user.delete(user_name)
    end
    
    @users.delete_at(index)
    true
  end

  def add_expense(amount, categories, payment_methods, date, description, user)
    expense = Expense.new(amount, categories, payment_methods, date, description, user)
    @expenses << expense
    true
  end

  def update_expense(index, params = {})
    return false if index < 0 || index >= @expenses.size
    
    expense = @expenses[index]
    
    expense.amount = params[:amount] if params[:amount]
    expense.categories = params[:categories] if params[:categories]
    expense.payment_methods = params[:payment_methods] if params[:payment_methods]
    expense.date = params[:date] if params[:date]
    expense.description = params[:description] if params[:description]
    expense.user = params[:user] if params[:user]
    
    true
  end

  def delete_expense(index)
    return false if index < 0 || index >= @expenses.size
    
    @expenses.delete_at(index)
    true
  end

  def save_data(filename, format = :json)
    data = {
      expenses: @expenses.map { |e| e.to_h(with_associations: true) }, 
      categories: @categories.map { |c| { name: c.name } }, 
      payment_methods: @payment_methods.map { |pm| { name: pm.name } },
      users: @users.map { |u| { name: u.name } }
    }
    
    file_extension = format == :yaml ? "yaml" : "json"
    full_filename = "#{filename}.#{file_extension}"
    
    begin
      case format
      when :yaml
        File.write(full_filename, data.to_yaml)
      else
        File.write(full_filename, JSON.pretty_generate(data))
      end
      
      return false if !File.exist?(full_filename) || File.size(full_filename) == 0
      true
    rescue => e
      puts "Помилка при збереженні: #{e.message}"
      false
    end
  end

  def load_data(filename, format = :json)
    file_extension = format == :yaml ? "yaml" : "json"
    full_filename = "#{filename}.#{file_extension}"
    
    return false unless File.exist?(full_filename)
    
    begin
      data = case format
             when :yaml then YAML.load_file(full_filename)
             else JSON.parse(File.read(full_filename), symbolize_names: true)
             end
  
      # Завантаження користувачів, категорій, способів оплати
      @users = (data[:users] || []).map { |u| User.new(u[:name]) }
      @categories = (data[:categories] || []).map { |c| Category.new(c[:name]) }
      @payment_methods = (data[:payment_methods] || []).map { |pm| PaymentMethod.new(pm[:name]) }
  
      @expenses = (data[:expenses] || []).map do |e|
        user = @users.find { |u| u.name == e[:user][:name] }
        categories = e[:categories].map { |c| @categories.find { |cat| cat.name == c[:name] } }
        payment_methods = e[:payment_methods].map { |pm| @payment_methods.find { |p| p.name == pm[:name] } }
  
        Expense.new(
          e[:amount],
          categories.compact, 
          payment_methods.compact,
          e[:date],
          e[:description],
          user
        )
      end
  
      true
    rescue => e
      puts "Помилка при завантаженні: #{e.message}"
      false
    end
  end

  def expenses_for_category(category_name)
    @expenses.select { |expense| expense.categories.include?(category_name) }
  end

  def expenses_for_payment_method(payment_method_name)
    @expenses.select { |expense| expense.payment_methods.include?(payment_method_name) }
  end

  def expenses_for_user(user_name)
    @expenses.select { |expense| expense.user == user_name }
  end

  def expenses_in_date_range(start_date, end_date)
    @expenses.select { |expense| expense.date >= start_date && expense.date <= end_date }
  end
end