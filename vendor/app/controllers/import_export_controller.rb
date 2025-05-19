require 'json'
require 'yaml'

class ImportExportController < ApplicationController
  def index
  end
  
  # Експорт в JSON
  def export_json
    data = prepare_export_data
    send_data data.to_json, 
      type: 'application/json', 
      disposition: 'attachment', 
      filename: "expenses_export_#{Time.now.strftime('%Y%m%d%H%M%S')}.json"
  end
  
  # Експорт в YAML
  def export_yaml
    data = prepare_export_data
    send_data data.to_yaml, 
      type: 'application/yaml', 
      disposition: 'attachment', 
      filename: "expenses_export_#{Time.now.strftime('%Y%m%d%H%M%S')}.yml"
  end
  
  # Імпорт з файлу
  def import
    if params[:file].nil?
      redirect_to import_export_path, alert: 'Виберіть файл для імпорту'
      return
    end
    
    file_content = params[:file].read
    
    if params[:file].content_type == 'application/json' || params[:file].original_filename.end_with?('.json')
      import_data(JSON.parse(file_content))
    elsif params[:file].content_type == 'application/yaml' || params[:file].original_filename.end_with?('.yml', '.yaml')
      import_data(YAML.safe_load(file_content))
    else
      redirect_to import_export_path, alert: 'Підтримуються лише файли JSON або YAML'
      return
    end
    
    redirect_to expenses_path, notice: 'Дані успішно імпортовано'
  end
  
  private
  
  def prepare_export_data
    {
      categories: Category.all.as_json(only: [:name]),
      payment_methods: PaymentMethod.all.as_json(only: [:name]),
      spenders: Spender.all.as_json(only: [:name]),
      expenses: Expense.all.as_json(
        only: [:amount, :date, :description],
        include: {
          categories: { only: [:name] },
          payment_methods: { only: [:name] },
          spender: { only: [:name] }
        }
      )
    }
  end
  
  def import_data(data)
    # Спочатку імпортуємо категорії
    if data['categories'].present?
      data['categories'].each do |category_data|
        Category.find_or_create_by!(name: category_data['name'])
      end
    end
    
    # Далі імпортуємо способи оплати
    if data['payment_methods'].present?
      data['payment_methods'].each do |payment_method_data|
        PaymentMethod.find_or_create_by!(name: payment_method_data['name'])
      end
    end

    if data['spenders'].present?
      data['spenders'].each do |spender_data|
        Spender.find_or_create_by!(name: spender_data['name'])
      end
    end
    
    # Тепер імпортуємо витрати
    if data['expenses'].present?
      data['expenses'].each do |expense_data|
        expense = Expense.new(
          amount: expense_data['amount'],
          date: expense_data['date'],
          description: expense_data['description']
        )

        if expense_data.dig('spender', 'name').present?
          spender = Spender.find_by!(name: expense_data['spender']['name'])
          expense.spender = spender
        end
        
        # Додаємо категорії
        if expense_data['categories'].present?
          expense_data['categories'].each do |category_data|
            category = Category.find_by(name: category_data['name'])
            expense.categories << category if category.present?
          end
        end
        
        # Додаємо способи оплати
        if expense_data['payment_methods'].present?
          expense_data['payment_methods'].each do |payment_method_data|
            payment_method = PaymentMethod.find_by(name: payment_method_data['name'])
            expense.payment_methods << payment_method if payment_method.present?
          end
        end
        
        expense.save!
      end
    end
  end
end