class PaymentMethodsController < ApplicationController
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

  def index
    @payment_methods = current_user.payment_methods
    
    # Пошук
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @payment_methods = @payment_methods.where("name LIKE ?", search_term)
    end
    
    # Сортування
    sort_column = %w[name].include?(params[:sort]) ? params[:sort] : 'name'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    @payment_methods = @payment_methods.order("#{sort_column} #{sort_direction}")
    
    # Пагінація
    @payment_methods = @payment_methods.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @payment_method = current_user.payment_methods.build
  end

  def edit
  end

  def create
    @payment_method = current_user.payment_methods.build(payment_method_params)

    if @payment_method.save
      redirect_to @payment_method, notice: t('payment_methods.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      redirect_to @payment_method, notice: t('payment_methods.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment_method.destroy
    redirect_to payment_methods_path, notice: t('payment_methods.destroyed')
  end

  private
    def set_payment_method
      @payment_method = current_user.payment_methods.find(params[:id])
    end

    def payment_method_params
      params.require(:payment_method).permit(:name)
    end
end