class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  before_action :set_collections, only: [:new, :edit, :create, :update]

  def index
    @expenses = Expense.all.order(date: :desc)
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
    end

    def expense_params
      params.require(:expense).permit(:amount, :date, :description, category_ids: [], payment_method_ids: [])
    end
end