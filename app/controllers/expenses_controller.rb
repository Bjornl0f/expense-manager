class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  before_action :set_collections, only: [:new, :edit, :create, :update]

  def index
    @expenses = current_user.expenses

    # Пошук
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @expenses = @expenses.where("description LIKE ?", search_term)
                           .or(current_user.expenses.where(id: current_user.categories.where("name LIKE ?", search_term)
                           .joins(:expenses).select(:expense_id)))
                           .or(current_user.expenses.where(id: current_user.payment_methods.where("name LIKE ?", search_term)
                           .joins(:expenses).select(:expense_id)))
                           .or(current_user.expenses.joins(:spender).where("spenders.name LIKE ?", search_term))
    end
    
    # Фільтр за категорією
    if params[:category_id].present?
      @expenses = @expenses.joins(:categories).where(categories: { id: params[:category_id], user_id: current_user.id })
    end
    
    # Фільтр за способом оплати
    if params[:payment_method_id].present?
      @expenses = @expenses.joins(:payment_methods).where(payment_methods: { id: params[:payment_method_id], user_id: current_user.id })
    end

    # Фільтр за платником
    if params[:spender_id].present?
      @expenses = @expenses.where(spender_id: params[:spender_id], user_id: current_user.id )
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
    @expense = current_user.expenses.build
  end

  def edit
  end

  def create
    @expense = current_user.expenses.build(expense_params)

    if @expense.save
      redirect_to @expense, notice: t('expenses.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to @expense, notice: t('expenses.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: t('expenses.destroyed')
  end

  private
    def set_expense
      @expense = current_user.expenses.find(params[:id])
    end

    def set_collections
      @spenders = current_user.spenders
      @categories = current_user.categories
      @payment_methods = current_user.payment_methods
    end

    def expense_params
      params.require(:expense).permit(:amount, :date, :description, :spender_id, category_ids: [], payment_method_ids: [])
    end
end