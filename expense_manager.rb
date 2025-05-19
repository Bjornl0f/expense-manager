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

  def run
    loop do
      show_main_menu
      choice = gets.chomp.to_i
      case choice
      when 1 then manage_users
      when 2 then manage_categories
      when 3 then manage_payment_methods
      when 4 then manage_expenses
      when 5 then generate_reports
      when 6 then save_data
      when 7 then load_data
      when 8 then break
      else puts "Невірний вибір. Спробуйте ще раз."
      end
    end
  end

  # ======== КЕРУВАННЯ КОРИСТУВАЧАМИ ========
  def manage_users
    loop do
      puts "\nКерування користувачами:"
      puts "1. Додати користувача"
      puts "2. Переглянути користувачів"
      puts "3. Редагувати користувача"
      puts "4. Видалити користувача"
      puts "5. Назад"
      print "Оберіть опцію: "
      
      case gets.chomp.to_i
      when 1
        add_user
      when 2
        view_users
      when 3
        edit_user
      when 4
        delete_user
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def add_user
    print "Введіть ім'я користувача: "
    name = gets.chomp.strip
    begin
      added_user = add_user_internal(name)
      puts "Користувача '#{added_user}' додано."
    rescue => e
      puts "Помилка: #{e.message}"
    end
  end
  
  def add_user_internal(name)
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
  
  def view_users
    list_items("Користувачі", @users)
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_user
    list_items("Користувачі", @users)
    
    if @users.empty?
      puts "Немає користувачів для редагування."
      return
    end
    
    print "Введіть індекс користувача для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= @users.size
      puts "Невірний індекс користувача."
      return
    end
    
    print "Введіть нове ім'я для користувача \"#{@users[index]}\": "
    new_name = gets.chomp.strip
    
    begin
      result = edit_user_internal(index, new_name)
      puts result
    rescue => e
      puts "Помилка: #{e.message}"
    end
  end
  
  def edit_user_internal(index, new_name)
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
  
  def delete_user
    list_items("Користувачі", @users)
    
    if @users.empty?
      puts "Немає користувачів для видалення."
      return
    end
    
    print "Введіть індекс для видалення: "
    index = gets.chomp.to_i
    
    begin
      user_name = @users[index]
      
      # Перевіряємо чи користувач має витрати
      expenses_with_user = @expenses.select { |e| e[:user] == user_name }
      
      if !expenses_with_user.empty?
        puts "Увага! Користувач має #{expenses_with_user.size} витрат."
        print "Операція видалення неможлива. Змініть власника витрат перед видаленням користувача."
        return
      end
      
      result = delete_user_internal(index)
      puts "Користувача '#{result}' видалено."
    rescue => e
      puts "Помилка: #{e.message}"
    end
  end
  
  def delete_user_internal(index)
    if index < 0 || index >= @users.size
      raise "Невірний індекс користувача."
    end
    
    user_name = @users[index]
    
    expenses_with_user = @expenses.select { |e| e[:user] == user_name }
    
    if !expenses_with_user.empty?
      raise "Неможливо видалити користувача, який має витрати. Спочатку видаліть або змініть його витрати."
    end
    
    @users.delete_at(index)
    return user_name
  end
  
  # ======== КЕРУВАННЯ КАТЕГОРІЯМИ ========
  def manage_categories
    loop do
      puts "\nКерування категоріями:"
      puts "1. Додати категорію"
      puts "2. Переглянути категорії"
      puts "3. Редагувати категорію"
      puts "4. Видалити категорію"
      puts "5. Назад"
      print "Оберіть опцію: "
      
      case gets.chomp.to_i
      when 1
        add_category
      when 2
        view_categories
      when 3
        edit_category
      when 4
        delete_category
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def add_category
    print "Введіть назву категорії: "
    name = gets.chomp.strip
    if name.empty? || @categories.include?(name)
      puts "Недійсна або вже існуюча категорія."
    else
      @categories << name
      puts "Категорію додано."
    end
  end
  
  def view_categories
    list_items("Категорії", @categories)
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_category
    list_items("Категорії", @categories)
    
    if @categories.empty?
      puts "Немає категорій для редагування."
      return
    end
    
    print "Введіть індекс категорії для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= @categories.size
      puts "Невірний індекс."
      return
    end
    
    print "Введіть нову назву для категорії \"#{@categories[index]}\": "
    new_name = gets.chomp.strip
    
    if new_name.empty? || (@categories.include?(new_name) && @categories[index] != new_name)
      puts "Недійсна або вже існуюча категорія."
    else
      old_name = @categories[index]
      @categories[index] = new_name
      
      # Оновлюємо категорію в усіх витратах
      @expenses.each do |expense|
        expense[:categories].map! { |cat| cat == old_name ? new_name : cat }
      end
      
      puts "Категорію оновлено."
    end
  end
  
  def delete_category
    list_items("Категорії", @categories)
    
    if @categories.empty?
      puts "Немає категорій для видалення."
      return
    end
    
    print "Введіть індекс для видалення: "
    i = gets.chomp.to_i
    
    if i >= 0 && i < @categories.size
      category_name = @categories[i]
      
      # Перевіряємо чи категорія використовується у витратах
      expenses_with_category = @expenses.select { |e| e[:categories].include?(category_name) }
      
      if !expenses_with_category.empty?
        puts "Увага! Категорія використовується у #{expenses_with_category.size} витратах."
        print "Все одно видалити? (т/н): "
        
        if gets.chomp.downcase != 'т'
          puts "Видалення скасовано."
          return
        end
        
        # Видаляємо категорію з усіх витрат
        @expenses.each do |expense|
          expense[:categories].delete(category_name)
        end
      end
      
      @categories.delete_at(i)
      puts "Категорія '#{category_name}' видалена."
    else
      puts "Невірний індекс."
    end
  end

  # ======== КЕРУВАННЯ СПОСОБАМИ ОПЛАТИ ========
  def manage_payment_methods
    loop do
      puts "\nКерування способами оплати:"
      puts "1. Додати спосіб оплати"
      puts "2. Переглянути способи оплати"
      puts "3. Редагувати спосіб оплати"
      puts "4. Видалити спосіб оплати"
      puts "5. Назад"
      print "Оберіть опцію: "
      
      case gets.chomp.to_i
      when 1
        add_payment_method
      when 2
        view_payment_methods
      when 3
        edit_payment_method
      when 4
        delete_payment_method
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def add_payment_method
    print "Введіть назву способу оплати: "
    name = gets.chomp.strip
    if name.empty? || @payment_methods.include?(name)
      puts "Недійсний або вже існуючий спосіб."
    else
      @payment_methods << name
      puts "Спосіб оплати додано."
    end
  end
  
  def view_payment_methods
    list_items("Способи оплати", @payment_methods)
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_payment_method
    list_items("Способи оплати", @payment_methods)
    
    if @payment_methods.empty?
      puts "Немає способів оплати для редагування."
      return
    end
    
    print "Введіть індекс способу оплати для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= @payment_methods.size
      puts "Невірний індекс."
      return
    end
    
    print "Введіть нову назву для способу оплати \"#{@payment_methods[index]}\": "
    new_name = gets.chomp.strip
    
    if new_name.empty? || (@payment_methods.include?(new_name) && @payment_methods[index] != new_name)
      puts "Недійсний або вже існуючий спосіб оплати."
    else
      old_name = @payment_methods[index]
      @payment_methods[index] = new_name
      
      # Оновлюємо спосіб оплати в усіх витратах
      @expenses.each do |expense|
        expense[:payment_methods].map! { |pm| pm == old_name ? new_name : pm }
      end
      
      puts "Спосіб оплати оновлено."
    end
  end
  
  def delete_payment_method
    list_items("Способи оплати", @payment_methods)
    
    if @payment_methods.empty?
      puts "Немає способів оплати для видалення."
      return
    end
    
    print "Введіть індекс для видалення: "
    i = gets.chomp.to_i
    
    if i >= 0 && i < @payment_methods.size
      payment_method_name = @payment_methods[i]
      
      # Перевіряємо чи спосіб оплати використовується у витратах
      expenses_with_payment = @expenses.select { |e| e[:payment_methods].include?(payment_method_name) }
      
      if !expenses_with_payment.empty?
        puts "Увага! Спосіб оплати використовується у #{expenses_with_payment.size} витратах."
        print "Все одно видалити? (т/н): "
        
        if gets.chomp.downcase != 'т'
          puts "Видалення скасовано."
          return
        end
        
        # Видаляємо спосіб оплати з усіх витрат
        @expenses.each do |expense|
          expense[:payment_methods].delete(payment_method_name)
        end
      end
      
      @payment_methods.delete_at(i)
      puts "Спосіб оплати '#{payment_method_name}' видалено."
    else
      puts "Невірний індекс."
    end
  end

  # ======== КЕРУВАННЯ ВИТРАТАМИ ========
  def manage_expenses
    loop do
      puts "\nКерування витратами:"
      puts "1. Додати витрату"
      puts "2. Переглянути витрати"
      puts "3. Редагувати витрату"
      puts "4. Видалити витрату"
      puts "5. Назад"
      print "Оберіть опцію: "
      
      case gets.chomp.to_i
      when 1
        add_expense
      when 2
        view_expenses
      when 3
        edit_expense
      when 4
        delete_expense
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def add_expense
    if @categories.empty? || @payment_methods.empty?
      puts "Спочатку створіть принаймні одну категорію і спосіб оплати."
      return
    end
    
    # Перевіряємо чи є користувачі
    if @users.empty?
      puts "Спочатку додайте користувача."
      return
    end

    amount = get_amount
    categories_indices = select_indices("категорії", @categories)
    payment_indices = select_indices("способи оплати", @payment_methods)
    date = get_date
    description = get_description
    user_index = select_user()

    begin
      selected_categories = categories_indices.map { |i| @categories[i] }.compact
      selected_payments = payment_indices.map { |i| @payment_methods[i] }.compact
      
      expense = {
        amount: amount,
        categories: selected_categories,
        payment_methods: selected_payments,
        date: date,
        description: description,
        user: @users[user_index]
      }
      
      @expenses << expense
      puts "Витрату успішно додано!"
    rescue => e
      puts "Помилка: #{e.message}"
    end
  end
  
  def select_user
    list_items("Користувачі", @users)
    loop do
      print "Виберіть користувача (введіть індекс): "
      index = gets.chomp.to_i
      if index >= 0 && index < @users.size
        return index
      else
        puts "Невірний індекс користувача. Спробуйте ще раз."
      end
    end
  end
  
  def view_expenses
    if @expenses.empty?
      puts "Список витрат порожній."
    else
      puts "\nВитрати:"
      @expenses.each_with_index do |exp, i|
        puts "#{i}. [#{exp[:date]}] #{exp[:description]} - #{exp[:amount]}₴"
        puts "   Користувач: #{exp[:user] || 'Не вказано'}"
        puts "   Категорії: #{exp[:categories].join(', ')}"
        puts "   Способи оплати: #{exp[:payment_methods].join(', ')}"
      end
    end
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_expense
    view_expenses
    
    if @expenses.empty?
      puts "Немає витрат для редагування."
      return
    end
    
    print "Введіть індекс витрати для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= @expenses.size
      puts "Невірний індекс."
      return
    end
    
    expense = @expenses[index]
    
    puts "\nРедагування витрати:"
    puts "1. Сума (поточна: #{expense[:amount]}₴)"
    puts "2. Категорії (поточні: #{expense[:categories].join(', ')})"
    puts "3. Способи оплати (поточні: #{expense[:payment_methods].join(', ')})" 
    puts "4. Дата (поточна: #{expense[:date]})"
    puts "5. Опис (поточний: #{expense[:description]})"
    puts "6. Користувач (поточний: #{expense[:user] || 'Не вказано'})"
    puts "7. Редагувати все"
    puts "8. Відмінити редагування"
    print "Оберіть, що редагувати: "
    
    choice = gets.chomp.to_i
    
    case choice
    when 1
      expense[:amount] = get_amount
      puts "Суму оновлено."
    when 2
      categories_indices = select_indices("категорії", @categories)
      expense[:categories] = categories_indices.map { |i| @categories[i] }.compact
      puts "Категорії оновлено."
    when 3
      payment_indices = select_indices("способи оплати", @payment_methods)
      expense[:payment_methods] = payment_indices.map { |i| @payment_methods[i] }.compact
      puts "Способи оплати оновлено."
    when 4
      expense[:date] = get_date
      puts "Дату оновлено."
    when 5
      expense[:description] = get_description
      puts "Опис оновлено."
    when 6
      user_index = select_user
      expense[:user] = @users[user_index]
      puts "Користувача оновлено."
    when 7
      expense[:amount] = get_amount
      categories_indices = select_indices("категорії", @categories)
      expense[:categories] = categories_indices.map { |i| @categories[i] }.compact
      payment_indices = select_indices("способи оплати", @payment_methods)
      expense[:payment_methods] = payment_indices.map { |i| @payment_methods[i] }.compact
      expense[:date] = get_date
      expense[:description] = get_description
      user_index = select_user
      expense[:user] = @users[user_index]
      puts "Всі дані витрати оновлено."
    when 8
      puts "Редагування скасовано."
    else
      puts "Невірний вибір."
    end
  end
  
  def delete_expense
    view_expenses
    
    if @expenses.empty?
      puts "Немає витрат для видалення."
      return
    end
    
    print "Введіть індекс витрати для видалення: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= @expenses.size
      puts "Невірний індекс."
      return
    end
    
    expense = @expenses[index]
    puts "Ви дійсно хочете видалити витрату:"
    puts "[#{expense[:date]}] #{expense[:description]} - #{expense[:amount]}₴"
    puts "Користувач: #{expense[:user] || 'Не вказано'}"
    print "Підтвердити видалення? (т/н): "
    
    if gets.chomp.downcase == 'т'
      @expenses.delete_at(index)
      puts "Витрату видалено."
    else
      puts "Видалення скасовано."
    end
  end

  # ======== ЗВІТИ ========
  def generate_reports
    loop do
      puts "\nЗвіти:"
      puts "1. Витрати за користувачем"
      puts "2. Загальна сума витрат за користувачем"
      puts "3. Всі витрати"
      puts "4. Назад"
      print "Оберіть опцію: "
      
      case gets.chomp.to_i
      when 1
        find_expenses_by_user_menu
      when 2
        total_expenses_by_user_menu
      when 3
        view_expenses
      when 4 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def find_expenses_by_user_menu
    list_items("Користувачі", @users)
    
    if @users.empty?
      puts "Немає користувачів у системі."
      return
    end
    
    print "Введіть індекс користувача: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= @users.size
      puts "Невірний індекс користувача."
      return
    end
    
    user_name = @users[index]
    result = find_expenses_by_user(user_name)
    
    if result.is_a?(String)
      puts result
    else
      puts "\nВитрати користувача #{user_name}:"
      if result.empty?
        puts "Витрат не знайдено."
      else
        result.each do |exp|
          puts "#{exp[:index]}. [#{exp[:date]}] #{exp[:description]} - #{exp[:amount]}₴"
          puts "   Категорії: #{exp[:categories].join(', ')}"
          puts "   Способи оплати: #{exp[:payment_methods].join(', ')}"
        end
      end
    end
    
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
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
  
  def total_expenses_by_user_menu
    list_items("Користувачі", @users)
    
    if @users.empty?
      puts "Немає користувачів у системі."
      return
    end
    
    print "Введіть індекс користувача: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= @users.size
      puts "Невірний індекс користувача."
      return
    end
    
    user_name = @users[index]
    result = total_expenses_by_user(user_name)
    
    if result.is_a?(String)
      puts result
    else
      puts "\nЗагальні витрати користувача #{result[:user]}:"
      puts "Кількість витрат: #{result[:expenses_count]}"
      puts "Загальна сума: #{result[:total_expenses]}₴"
    end
    
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
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

  # ======== ЗБЕРЕЖЕННЯ І ЗАВАНТАЖЕННЯ ДАНИХ ========
  def save_data
    puts "\nФормат файлу:"
    puts "1. JSON"
    puts "2. YAML"
    print "Оберіть формат: "
    format = gets.chomp.to_i

    print "Введіть ім'я файлу (без розширення): "
    filename_base = gets.chomp

    format_sym = format == 2 ? :yaml : :json
    
    begin
      saved_file = save_data_internal(filename_base, format_sym)
      puts "Дані збережено у #{saved_file}"
    rescue => e
      puts "Помилка при збереженні: #{e.message}"
    end
  end
  
  def save_data_internal(filename, format = :json)
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

  def load_data
    puts "\nФормат файлу:"
    puts "1. JSON"
    puts "2. YAML"
    print "Оберіть формат: "
    format = gets.chomp.to_i

    print "Введіть ім'я файлу (без розширення): "
    filename_base = gets.chomp

    filename = case format
              when 2 then "#{filename_base}.yaml"
              else "#{filename_base}.json"
              end
              
    begin
      stats = load_data_internal(filename)
      puts "Дані успішно завантажено!"
      puts "Завантажено: #{stats[:users]} користувачів, #{stats[:expenses]} витрат, #{stats[:categories]} категорій, #{stats[:payment_methods]} способів оплати"
    rescue => e
      puts "Помилка при завантаженні: #{e.message}"
    end
  end
  
  def load_data_internal(filename)
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

  private

  def show_main_menu
    puts "\nГоловне меню:"
    puts "1. Керування користувачами"
    puts "2. Керування категоріями"
    puts "3. Керування способами оплати"
    puts "4. Керування витратами"
    puts "5. Звіти"
    puts "6. Зберегти дані"
    puts "7. Завантажити дані"
    puts "8. Вийти"
    print "Оберіть опцію: "
  end

  def select_from_list(label, list)
    puts "Оберіть #{label} (через кому, індекси):"
    list.each_with_index { |item, i| puts "#{i}. #{item}" }
    indices = gets.chomp.split(',').map(&:strip).map(&:to_i)
    selected = indices.map { |i| list[i] }.compact
    selected.empty? ? (puts "Не обрано жодного. Спробуйте ще раз."; select_from_list(label, list)) : selected
  end

  def list_items(label, list)
    puts "\n#{label}:"
    if list.empty?
      puts "Список порожній."
    else
      list.each_with_index { |item, i| puts "#{i}. #{item}" }
    end
  end
end

ExpenseManager.new.run