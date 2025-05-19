require_relative 'expense'
require_relative 'category'
require_relative 'payment_method'
require_relative 'data_manager'

class Interface
  def initialize(data_manager)
    @data_manager = data_manager
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
      when 1 then add_user
      when 2 then view_users
      when 3 then edit_user
      when 4 then delete_user
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end

  def add_user
    print "Введіть ім'я користувача: "
    name = gets.chomp.strip
    
    if @data_manager.add_user(name)
      puts "Користувача додано."
    else
      puts "Недійсне або вже існуюче ім'я користувача."
    end
  end
  
  def view_users
    users = @data_manager.users
    list_items("Користувачі", users)
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_user
    users = @data_manager.users
    list_items("Користувачі", users)
    
    if users.empty?
      puts "Немає користувачів для редагування."
      return
    end
    
    print "Введіть індекс користувача для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= users.size
      puts "Невірний індекс."
      return
    end
    
    print "Введіть нове ім'я для користувача \"#{users[index]}\": "
    new_name = gets.chomp.strip
    
    if @data_manager.update_user(index, new_name)
      puts "Користувача оновлено."
    else
      puts "Недійсне або вже існуюче ім'я."
    end
  end
  
  def delete_user
    users = @data_manager.users
    list_items("Користувачі", users)
    
    if users.empty?
      puts "Немає користувачів для видалення."
      return
    end
    
    print "Введіть індекс для видалення: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= users.size
      puts "Невірний індекс."
      return
    end
    
    user_name = users[index].name
    expenses_with_user = @data_manager.expenses_for_user(user_name)
    
    if !expenses_with_user.empty?
      puts "Увага! Користувач використовується у #{expenses_with_category.size} витратах."
      print "Все одно видалити? (т/н): "
      
      if gets.chomp.downcase != 'т'
        puts "Видалення скасовано."
        return
      end
    end
    
    if @data_manager.delete_user(index)
      puts "Користувач '#{category_name}' видалений."
    else
      puts "Помилка при видаленні користувача."
    end
  end

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
      when 1 then add_category
      when 2 then view_categories
      when 3 then edit_category
      when 4 then delete_category
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def add_category
    print "Введіть назву категорії: "
    name = gets.chomp.strip
    
    if @data_manager.add_category(name)
      puts "Категорію додано."
    else
      puts "Недійсна або вже існуюча категорія."
    end
  end
  
  def view_categories
    categories = @data_manager.categories
    list_items("Категорії", categories)
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_category
    categories = @data_manager.categories
    list_items("Категорії", categories)
    
    if categories.empty?
      puts "Немає категорій для редагування."
      return
    end
    
    print "Введіть індекс категорії для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= categories.size
      puts "Невірний індекс."
      return
    end
    
    print "Введіть нову назву для категорії \"#{categories[index]}\": "
    new_name = gets.chomp.strip
    
    if @data_manager.update_category(index, new_name)
      puts "Категорію оновлено."
    else
      puts "Недійсна або вже існуюча категорія."
    end
  end
  
  def delete_category
    categories = @data_manager.categories
    list_items("Категорії", categories)
    
    if categories.empty?
      puts "Немає категорій для видалення."
      return
    end
    
    print "Введіть індекс для видалення: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= categories.size
      puts "Невірний індекс."
      return
    end
    
    category_name = categories[index].name
    expenses_with_category = @data_manager.expenses_for_category(category_name)
    
    if !expenses_with_category.empty?
      puts "Увага! Категорія використовується у #{expenses_with_category.size} витратах."
      print "Все одно видалити? (т/н): "
      
      if gets.chomp.downcase != 'т'
        puts "Видалення скасовано."
        return
      end
    end
    
    if @data_manager.delete_category(index)
      puts "Категорія '#{category_name}' видалена."
    else
      puts "Помилка при видаленні категорії."
    end
  end

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
      when 1 then add_payment_method
      when 2 then view_payment_methods
      when 3 then edit_payment_method
      when 4 then delete_payment_method
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def add_payment_method
    print "Введіть назву способу оплати: "
    name = gets.chomp.strip
    
    if @data_manager.add_payment_method(name)
      puts "Спосіб оплати додано."
    else
      puts "Недійсний або вже існуючий спосіб."
    end
  end
  
  def view_payment_methods
    payment_methods = @data_manager.payment_methods
    list_items("Способи оплати", payment_methods)
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_payment_method
    payment_methods = @data_manager.payment_methods
    list_items("Способи оплати", payment_methods)
    
    if payment_methods.empty?
      puts "Немає способів оплати для редагування."
      return
    end
    
    print "Введіть індекс способу оплати для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= payment_methods.size
      puts "Невірний індекс."
      return
    end
    
    print "Введіть нову назву для способу оплати \"#{payment_methods[index]}\": "
    new_name = gets.chomp.strip
    
    if @data_manager.update_payment_method(index, new_name)
      puts "Спосіб оплати оновлено."
    else
      puts "Недійсний або вже існуючий спосіб оплати."
    end
  end
  
  def delete_payment_method
    payment_methods = @data_manager.payment_methods
    list_items("Способи оплати", payment_methods)
    
    if payment_methods.empty?
      puts "Немає способів оплати для видалення."
      return
    end
    
    print "Введіть індекс для видалення: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= payment_methods.size
      puts "Невірний індекс."
      return
    end
    
    payment_method_name = payment_methods[index].name
    expenses_with_payment = @data_manager.expenses_for_payment_method(payment_method_name)
    
    if !expenses_with_payment.empty?
      puts "Увага! Спосіб оплати використовується у #{expenses_with_payment.size} витратах."
      print "Все одно видалити? (т/н): "
      
      if gets.chomp.downcase != 'т'
        puts "Видалення скасовано."
        return
      end
    end
    
    if @data_manager.delete_payment_method(index)
      puts "Спосіб оплати '#{payment_method_name}' видалено."
    else
      puts "Помилка при видаленні способу оплати."
    end
  end

  # Методи для керування витратами
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
      when 1 then add_expense
      when 2 then view_expenses
      when 3 then edit_expense
      when 4 then delete_expense
      when 5 then break
      else puts "Невірний вибір."
      end
    end
  end
  
  def add_expense
    categories = @data_manager.categories
    payment_methods = @data_manager.payment_methods
    users = @data_manager.users
    
    if categories.empty? || payment_methods.empty? || users.empty?
      puts "Спочатку створіть принаймні одну категорію, спосіб оплати і користувача який здійснив витрату."
      return
    end

    amount = get_amount
    selected_categories = select_from_list("категорії", categories.map(&:name))
    selected_payments = select_from_list("способи оплати", payment_methods.map(&:name))
    date = get_date
    description = get_description
    selected_user = select_user_from_list(users.map(&:name))

    if @data_manager.add_expense(amount, selected_categories, selected_payments, date, description, selected_user)
      puts "Витрату успішно додано!"
    else
      puts "Помилка при додаванні витрати."
    end
  end
  
  def view_expenses
    expenses = @data_manager.expenses
    
    if expenses.empty?
      puts "Список витрат порожній."
    else
      puts "\nВитрати:"
      expenses.each_with_index do |expense, i|
        puts "#{i}. #{expense}"
        puts expense.details
      end
    end
    puts "Натисніть Enter, щоб продовжити..."
    gets
  end
  
  def edit_expense
    expenses = @data_manager.expenses
    view_expenses
    
    if expenses.empty?
      puts "Немає витрат для редагування."
      return
    end
    
    print "Введіть індекс витрати для редагування: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= expenses.size
      puts "Невірний індекс."
      return
    end
    
    expense = expenses[index]
    
    puts "\nРедагування витрати:"
    puts "1. Сума (поточна: #{expense.amount}₴)"
    puts "2. Категорії (поточні: #{expense.categories.join(', ')})"
    puts "3. Способи оплати (поточні: #{expense.payment_methods.join(', ')})"
    puts "4. Дата (поточна: #{expense.date})"
    puts "5. Опис (поточний: #{expense.description})"
    puts "6. Користувач (поточний: #{expense.user})"
    puts "7. Редагувати все"
    puts "8. Відмінити редагування"
    print "Оберіть, що редагувати: "
    
    choice = gets.chomp.to_i
    
    case choice
    when 1
      params = { amount: get_amount }
      if @data_manager.update_expense(index, params)
        puts "Суму оновлено."
      end
    when 2
      categories = @data_manager.categories
      params = { categories: select_from_list("категорії", categories.map(&:name)) }
      if @data_manager.update_expense(index, params)
        puts "Категорії оновлено."
      end
    when 3
      payment_methods = @data_manager.payment_methods
      params = { payment_methods: select_from_list("способи оплати", payment_methods.map(&:name)) }
      if @data_manager.update_expense(index, params)
        puts "Способи оплати оновлено."
      end
    when 4
      params = { date: get_date }
      if @data_manager.update_expense(index, params)
        puts "Дату оновлено."
      end
    when 5
      params = { description: get_description }
      if @data_manager.update_expense(index, params)
        puts "Опис оновлено."
      end
    when 6
      params = { user: select_user_from_list(users.map(&:name)) }
      if @data_manager.update_user(index, params)
        puts "Користувача оновлено"
      end
    when 7
      categories = @data_manager.categories
      payment_methods = @data_manager.payment_methods
      users = @data_manager.users
      
      params = {
        amount: get_amount,
        categories: select_from_list("категорії", categories.map(&:name)),
        payment_methods: select_from_list("способи оплати", payment_methods.map(&:name)),
        date: get_date,
        description: get_description,
        user: select_user_from_list(users.map(&:name)) 
      }
      
      if @data_manager.update_expense(index, params)
        puts "Всі дані витрати оновлено."
      end
    when 8
      puts "Редагування скасовано."
    else
      puts "Невірний вибір."
    end
  end
  
  def delete_expense
    expenses = @data_manager.expenses
    view_expenses
    
    if expenses.empty?
      puts "Немає витрат для видалення."
      return
    end
    
    print "Введіть індекс витрати для видалення: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= expenses.size
      puts "Невірний індекс."
      return
    end
    
    expense = expenses[index]
    puts "Ви дійсно хочете видалити витрату:"
    puts "#{expense}"
    print "Підтвердити видалення? (т/н): "
    
    if gets.chomp.downcase == 'т'
      if @data_manager.delete_expense(index)
        puts "Витрату видалено."
      else
        puts "Помилка при видаленні витрати."
      end
    else
      puts "Видалення скасовано."
    end
  end

  def get_amount
    loop do
      print "Введіть суму: "
      input = gets.chomp
      return input.to_f if input =~ /^\d+(\.\d+)?$/
      puts "Невірна сума!"
    end
  end

  def get_date
    loop do
      print "Введіть дату (YYYY-MM-DD): "
      input = gets.chomp
      return input if input =~ /^\d{4}-\d{2}-\d{2}$/
      puts "Невірний формат дати!"
    end
  end

  def get_description
    print "Введіть опис: "
    gets.chomp
  end

  def select_from_list(label, list)
    puts "Оберіть #{label} (через кому, індекси):"
    list.each_with_index { |item, i| puts "#{i}. #{item}" }
    indices = gets.chomp.split(',').map(&:strip).map(&:to_i)
    selected = indices.map { |i| list[i] }.compact
    selected.empty? ? (puts "Не обрано жодного. Спробуйте ще раз."; select_from_list(label, list)) : selected
  end

  def select_user_from_list(list)
    loop do
      puts "Оберіть користувача (індекс):"
      list.each_with_index { |item, i| puts "#{i}. #{item}" }
      selected = gets.chomp.strip
  
      # Перевірка на порожній ввід
      if selected.empty?
        puts "Помилка: Не обрано жодного. Спробуйте ще раз."
        next
      end
  
      # Перевірка, чи введене значення — число
      unless selected.match?(/^\d+$/)
        puts "Помилка: Введіть числовий індекс. Спробуйте ще раз."
        next
      end
  
      index = selected.to_i
  
      # Перевірка, чи індекс в межах списку
      if index.between?(0, list.size - 1)
        return list[index] # Повертаємо обраний елемент
      else
        puts "Помилка: Невірний індекс. Спробуйте ще раз."
      end
    end
  end

  def list_items(label, list)
    puts "\n#{label}:"
    if list.empty?
      puts "Список порожній."
    else
      list.each_with_index { |item, i| puts "#{i}. #{item}" }
    end
  end

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
    users = @data_manager.users
    list_items("Користувачі", users)
    
    if users.empty?
      puts "Немає користувачів у системі."
      return
    end
    
    print "Введіть індекс користувача: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= users.size
      puts "Невірний індекс користувача."
      return
    end
    
    user_name = users[index]
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
    unless @data_manager.users.include?(user_name)
      return "Користувача '#{user_name}' не знайдено."
    end
  
    result = @data_manager.expenses_for_user(user_name)
    if result.empty?
      "Витрат користувача '#{user_name}' не знайдено."
    else
      result.each_with_index.map do |exp, i|
        {
          index: i,
          date: exp.date,         
          description: exp.description,
          amount: exp.amount,
          categories: exp.categories.map(&:name),
          payment_methods: exp.payment_methods.map(&:name),
          user: exp.user.name
        }
      end
    end
  end
  
  def total_expenses_by_user_menu
    users = @data_manager.users
    list_items("Користувачі", users)
    
    if users.empty?
      puts "Немає користувачів у системі."
      return
    end
    
    print "Введіть індекс користувача: "
    index = gets.chomp.to_i
    
    if index < 0 || index >= users.size
      puts "Невірний індекс користувача."
      return
    end
    
    user_name = users[index]
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
    unless @data_manager.users.include?(user_name)
      return "Користувача '#{user_name}' не знайдено."
    end
    
    result = @data_manager.expenses_for_user(user_name)
    if result.empty?
      return "Витрат користувача '#{user_name}' не знайдено."
    else
      total = result.sum { |exp| exp.amount }
      return {
        user: user_name,
        total_expenses: total,
        expenses_count: result.size
      }
    end
  end

  def save_data
    puts "\nФормат файлу:"
    puts "1. JSON"
    puts "2. YAML"
    print "Оберіть формат: "
    format = gets.chomp.to_i

    print "Введіть ім'я файлу (без розширення): "
    filename = gets.chomp

    format_sym = format == 2 ? :yaml : :json
    
    if @data_manager.save_data(filename, format_sym)
      puts "Дані збережено у #{filename}.#{format_sym}"
    else
      puts "Помилка при збереженні даних."
    end
  end

  def load_data
    puts "\nФормат файлу:"
    puts "1. JSON"
    puts "2. YAML"
    print "Оберіть формат: "
    format = gets.chomp.to_i

    print "Введіть ім'я файлу (без розширення): "
    filename = gets.chomp

    format_sym = format == 2 ? :yaml : :json
    
    if @data_manager.load_data(filename, format_sym)
      puts "Дані успішно завантажено!"
    else
      puts "Помилка при завантаженні даних."
    end
  end
end