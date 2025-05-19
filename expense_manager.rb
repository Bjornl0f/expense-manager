require 'json'
require 'yaml'

class ExpenseManager
  attr_reader :expenses, :categories, :payment_methods, :users

  def initialize
    @expenses = []
    @categories = []
    @payment_methods = []
    @users = []  
  end

  def add_user(name)
    name = name.strip
    if name.empty?
      raise "Ім'я користувача відсутнє"
    elsif @users.include?(name)
      raise "Користувач з таким ім'ям вже існує"
    else
      @users << name
      return name
    end
  end

  def edit_user(index, new_name)
    new_name = new_name.strip
    
    if index < 0 || index >= @users.size
      raise "Невірний індекс користувача."
    end
    
    if new_name.empty?
      raise "Ім'я користувача відсутнє"
    elsif @users.include?(new_name) && @users[index] != new_name
      raise "Користувач з таким ім'ям вже існує"
    else
      old_name = @users[index]
      @users[index] = new_name
      
      @expenses.each do |expense|
        if expense[:user] == old_name
          expense[:user] = new_name
        end
      end
      
      return "Користувача змінено з '#{old_name}' на '#{new_name}'"
    end
  end
  
  def delete_user(index)
    if index < 0 || index >= @users.size
      raise "Невірний індекс користувача."
    end
    
    user_name = @users[index]
    
    expenses_with_user = @expenses.select { |e| e[:user] == user_name }
    
    if !expenses_with_user.empty?
      raise "Неможливо видалити користувача, який має витрати. Спочатку видаліть або змініть його витрати."
    end
    
    @users.delete_at(index)
    return "Користувача '#{user_name}' видалено"
  end
  
  def view_users
    @users.each_with_index.map { |item, i| "#{i}. #{item}" }
  end

  # Методи управління категоріями
  def add_category(name)
    name = name.strip
    if name.empty? || @categories.include?(name)
      raise "Недійсна або вже існуюча категорія."
    else
      @categories << name
      return name
    end
  end
  
  def view_categories
    @categories.each_with_index.map { |item, i| "#{i}. #{item}" }
  end
  
  def edit_category(index, new_name)
    new_name = new_name.strip
    
    if index < 0 || index >= @categories.size
      raise "Невірний індекс."
    end
    
    if new_name.empty? || (@categories.include?(new_name) && @categories[index] != new_name)
      raise "Недійсна або вже існуюча категорія."
    else
      old_name = @categories[index]
      @categories[index] = new_name
      
      # Оновлюємо категорію в усіх витратах
      @expenses.each do |expense|
        expense[:categories].map! { |cat| cat == old_name ? new_name : cat }
      end
      
      return new_name
    end
  end
  
  def delete_category(index)
    if index < 0 || index >= @categories.size
      raise "Невірний індекс."
    end
    
    category_name = @categories[index]
    
    # Перевіряємо чи категорія використовується у витратах
    expenses_with_category = @expenses.select { |e| e[:categories].include?(category_name) }
    
    if !expenses_with_category.empty?
      # Видаляємо категорію з усіх витрат
      @expenses.each do |expense|
        expense[:categories].delete(category_name)
      end
    end
    
    @categories.delete_at(index)
    return category_name
  end

  # Методи управління способами оплати
  def add_payment_method(name)
    name = name.strip
    if name.empty? || @payment_methods.include?(name)
      raise "Недійсний або вже існуючий спосіб."
    else
      @payment_methods << name
      return name
    end
  end
  
  def view_payment_methods
    @payment_methods.each_with_index.map { |item, i| "#{i}. #{item}" }
  end
  
  def edit_payment_method(index, new_name)
    new_name = new_name.strip
    
    if index < 0 || index >= @payment_methods.size
      raise "Невірний індекс."
    end
    
    if new_name.empty? || (@payment_methods.include?(new_name) && @payment_methods[index] != new_name)
      raise "Недійсний або вже існуючий спосіб оплати."
    else
      old_name = @payment_methods[index]
      @payment_methods[index] = new_name
      
      # Оновлюємо спосіб оплати в усіх витратах
      @expenses.each do |expense|
        expense[:payment_methods].map! { |pm| pm == old_name ? new_name : pm }
      end
      
      return new_name
    end
  end
  
  def delete_payment_method(index)
    if index < 0 || index >= @payment_methods.size
      raise "Невірний індекс."
    end
    
    payment_method_name = @payment_methods[index]
    
    # Перевіряємо чи спосіб оплати використовується у витратах
    expenses_with_payment = @expenses.select { |e| e[:payment_methods].include?(payment_method_name) }
    
    if !expenses_with_payment.empty?
      # Видаляємо спосіб оплати з усіх витрат
      @expenses.each do |expense|
        expense[:payment_methods].delete(payment_method_name)
      end
    end
    
    @payment_methods.delete_at(index)
    return payment_method_name
  end

  # Методи управління витратами
  def add_expense(amount, categories_indices, payment_methods_indices, date, description, user_index)
    if @categories.empty? || @payment_methods.empty?
      raise "Спочатку створіть принаймні одну категорію і спосіб оплати."
    end

    # Перевіряємо чи є користувачі
    if @users.empty?
      raise "Спочатку додайте користувача."
    end

    if user_index < 0 || user_index >= @users.size
      raise "Невірний індекс користувача."
    end

    selected_user = @users[user_index]

    # Валідуємо значення
    unless amount.is_a?(Numeric) || (amount.is_a?(String) && amount =~ /^\d+(\.\d+)?$/)
      raise "Невірна сума!"
    end
    amount = amount.to_f
    
    # Валідуємо дату
    unless date =~ /^\d{4}-\d{2}-\d{2}$/
      raise "Невірний формат дати!"
    end
    
    # Вибрані категорії
    selected_categories = categories_indices.map { |i| @categories[i] }.compact
    if selected_categories.empty?
      raise "Не обрано жодної категорії."
    end
    
    # Вибрані способи оплати
    selected_payments = payment_methods_indices.map { |i| @payment_methods[i] }.compact
    if selected_payments.empty?
      raise "Не обрано жодного способу оплати."
    end

    expense = {
      amount: amount,
      categories: selected_categories,
      payment_methods: selected_payments,
      date: date,
      description: description,
      user: selected_user  # Додаємо користувача до витрати
    }
    
    @expenses << expense
    return expense
  end
  
  def view_expenses
    @expenses.each_with_index.map do |exp, i|
      {
        index: i,
        date: exp[:date],
        description: exp[:description],
        amount: exp[:amount],
        categories: exp[:categories],
        payment_methods: exp[:payment_methods],
        user: exp[:user]  # Додаємо користувача до результату
      }
    end
  end
  
  def edit_expense(index, field, new_value)
    if index < 0 || index >= @expenses.size
      raise "Невірний індекс."
    end
    
    expense = @expenses[index]
    
    case field
    when :amount
      unless new_value.is_a?(Numeric) || (new_value.is_a?(String) && new_value =~ /^\d+(\.\d+)?$/)
        raise "Невірна сума!"
      end
      expense[:amount] = new_value.to_f
      
    when :categories
      # Очікується масив індексів
      selected_categories = new_value.map { |i| @categories[i] }.compact
      if selected_categories.empty?
        raise "Не обрано жодної категорії."
      end
      expense[:categories] = selected_categories
      
    when :payment_methods
      # Очікується масив індексів
      selected_payments = new_value.map { |i| @payment_methods[i] }.compact
      if selected_payments.empty?
        raise "Не обрано жодного способу оплати."
      end
      expense[:payment_methods] = selected_payments
      
    when :date
      unless new_value =~ /^\d{4}-\d{2}-\d{2}$/
        raise "Невірний формат дати!"
      end
      expense[:date] = new_value
      
    when :description
      expense[:description] = new_value.to_s
    
    when :user
      if new_value < 0 || new_value >= @users.size
        raise "Невірний індекс користувача."
      end
      expense[:user] = @users[new_value]
      
    else
      raise "Невідоме поле для редагування."
    end
    
    return expense
  end
  
  def delete_expense(index)
    if index < 0 || index >= @expenses.size
      raise "Невірний індекс."
    end
    
    deleted_expense = @expenses.delete_at(index)
    return deleted_expense
  end

  # Функція пошуку витрат за користувачем
  def find_expenses_by_user(user_name)
    # Перевіряємо чи існує такий користувач
    unless @users.include?(user_name)
      return "Користувача '#{user_name}' не знайдено."
    end
    
    result = @expenses.select { |exp| exp[:user] == user_name }
    if result.empty?
      return "Витрат користувача '#{user_name}' не знайдено."
    else
      return result.each_with_index.map do |exp, i|
        {
          index: i,
          date: exp[:date],
          description: exp[:description],
          amount: exp[:amount],
          categories: exp[:categories],
          payment_methods: exp[:payment_methods],
          user: exp[:user]
        }
      end
    end
  end
  
  # Функція для отримання загальної суми витрат за користувачем
  def total_expenses_by_user(user_name)
    unless @users.include?(user_name)
      return "Користувача '#{user_name}' не знайдено."
    end
    
    result = @expenses.select { |exp| exp[:user] == user_name }
    if result.empty?
      return "Витрат користувача '#{user_name}' не знайдено."
    else
      total = result.sum { |exp| exp[:amount] }
      return {
        user: user_name,
        total_expenses: total,
        expenses_count: result.size
      }
    end
  end

  # Методи збереження/завантаження даних
  def save_data(filename, format = :json)
    data = {
      users: @users,  
      expenses: @expenses,
      categories: @categories,
      payment_methods: @payment_methods
    }

    case format
    when :json
      filename += ".json" unless filename.end_with?(".json")
      File.write(filename, JSON.pretty_generate(data))
    when :yaml
      filename += ".yaml" unless filename.end_with?(".yaml") || filename.end_with?(".yml")
      File.write(filename, data.to_yaml)
    else
      raise "Невідомий формат файлу: #{format}"
    end
    
    begin
      # Перевірка на успішність запису
      if !File.exist?(filename) || File.size(filename) == 0
        raise "Помилка при збереженні даних."
      end
    rescue => e
      raise "Помилка при збереженні: #{e.message}"
    end

    return filename
  end

  def load_data(filename)
    unless File.exist?(filename)
      raise "Файл не знайдено: #{filename}"
    end
    
    format = case filename
             when /\.json$/i then :json
             when /\.ya?ml$/i then :yaml
             else
               raise "Невідомий формат файлу: #{filename}"
             end

    data = case format
           when :json
             JSON.parse(File.read(filename), symbolize_names: true)
           when :yaml
             YAML.load_file(filename)
           end

    @users = data[:users] || []  
    @expenses = data[:expenses] || []
    @categories = data[:categories] || []
    @payment_methods = data[:payment_methods] || []
    
    return {
      users: @users.size,
      expenses: @expenses.size,
      categories: @categories.size,
      payment_methods: @payment_methods.size
    }
  end
end


manager = ExpenseManager.new

manager.add_user("Іван Петренко")
manager.add_user("Марія Коваленко")
manager.add_user("Петро Іваненко")
puts "Користувачі:"
puts manager.view_users

manager.add_category("Продукти")
manager.add_category("Транспорт")
manager.add_category("Розваги")

manager.add_payment_method("Готівка")
manager.add_payment_method("Кредитна картка")

puts "Категорії:"
puts manager.view_categories

manager.add_expense(125.50, [0, 2], [1], "2025-05-16", "Вечеря в ресторані", 0)

manager.add_expense(50.0, [1], [0], "2025-05-17", "Проїзд в таксі", 1)

manager.add_expense(200.0, [0], [1], "2025-05-18", "Покупки в супермаркеті", 0)

puts "Витрати:"
p manager.view_expenses

puts "Витрати Івана:"
p manager.find_expenses_by_user("Іван Петренко")

puts "Загальна сума витрат Івана:"
p manager.total_expenses_by_user("Іван Петренко")

manager.edit_expense(1, :user, 2)  

puts "Витрати після редагування:"
p manager.view_expenses

manager.save_data("my_expenses", :json)

loaded_data = manager.load_data("my_expenses.json")
puts "Завантажено дані: #{loaded_data}"