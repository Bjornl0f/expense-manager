class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  before_action :set_collections, only: [:new, :edit, :create, :update]

  def index
    @expenses = Expense.all

    # Пошук
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @expenses = @expenses.where("description LIKE ?", search_term)
                           .or(Expense.where(id: Category.where("name LIKE ?", search_term)
                           .joins(:expenses).select(:expense_id)))
                           .or(Expense.where(id: PaymentMethod.where("name LIKE ?", search_term)
                           .joins(:expenses).select(:expense_id)))
                           .or(Expense.joins(:spender).where("spenders.name LIKE ?", search_term))
    end
    
    # Фільтр за категорією
    if params[:category_id].present?
      @expenses = @expenses.joins(:categories).where(categories: { id: params[:category_id] })
    end
    
    # Фільтр за способом оплати
    if params[:payment_method_id].present?
      @expenses = @expenses.joins(:payment_methods).where(payment_methods: { id: params[:payment_method_id] })
    end
    
    # Фільтр за платником
    if params[:spender_id].present?
      @expenses = @expenses.where(spender_id: params[:spender_id])
    end
    
    # Сортування
    sort_column = %w[date amount description].include?(params[:sort]) ? params[:sort] : 'date'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    @expenses = @expenses.order("#{sort_column} #{sort_direction}")
    
    # Пагінація
    @expenses = @expenses.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @expense = Expense.new
  end

  def edit
  end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save
      redirect_to @expense, notice: 'Витрату успішно створено.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to @expense, notice: 'Витрату успішно оновлено.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: 'Витрату успішно видалено.'
  end

  private
    def set_expense
      @expense = Expense.find(params[:id])
    end

    def set_collections
      @categories = Category.all
      @payment_methods = PaymentMethod.all
      @spenders = Spender.all
    end

    def expense_params
      params.require(:expense).permit(:amount, :date, :description, :spender_id, category_ids: [], payment_method_ids: [])
    end
end