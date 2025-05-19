class SpendersController < ApplicationController
  before_action :set_spender, only: [:show, :edit, :update, :destroy]

  def index
    @spenders = current_user.spenders

    # Пошук
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @spenders = @spenders.where("name LIKE ?", search_term)
    end
    
    # Сортування
    sort_column = %w[name].include?(params[:sort]) ? params[:sort] : 'name'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    @spenders = @spenders.order("#{sort_column} #{sort_direction}")
    
    # Пагінація
    @spenders = @spenders.page(params[:page]).per(10)
  end

  def show
    # Сортування витрат платника
    sort_column = %w[date amount description].include?(params[:sort]) ? params[:sort] : 'date'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    
    # Отримати пов'язані витрати з сортуванням
    @expenses = @spender.expenses.order("#{sort_column} #{sort_direction}")
    
    # Пагінація для витрат на сторінці деталей платника
    @expenses = @expenses.page(params[:page]).per(5)
  end

  def new
    @spender = current_user.spenders.build
  end

  def edit
  end

  def create
    @spender = current_user.spenders.build(spender_params)

    if @spender.save
      redirect_to @spender, notice: t('spenders.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @spender.update(spender_params)
      redirect_to @spender, notice: t('spenders.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @spender.destroy
    redirect_to spenders_path, notice: t('spenders.deleted')
  end

  private
    def set_spender
      @spender = current_user.spenders.find(params[:id])
    end

    def spender_params
      params.require(:spender).permit(:name)
    end
end