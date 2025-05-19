class PaymentMethodsController < ApplicationController
  before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

  def index
    @payment_methods = PaymentMethod.all
  end

  def show
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def edit
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)

    if @payment_method.save
      redirect_to @payment_method, notice: 'Спосіб оплати успішно створено.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      redirect_to @payment_method, notice: 'Спосіб оплати успішно оновлено.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment_method.destroy
    redirect_to payment_methods_path, notice: 'Спосіб оплати успішно видалено.'
  end

  private
    def set_payment_method
      @payment_method = PaymentMethod.find(params[:id])
    end

    def payment_method_params
      params.require(:payment_method).permit(:name)
    end
end