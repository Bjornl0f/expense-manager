class SpendersController < ApplicationController
  before_action :set_spender, only: [:show, :edit, :update, :destroy]

  def index
    @spenders = Spender.all
  end

  def show
  end

  def new
    @spender = Spender.new
  end

  def edit
  end

  def create
    @spender = Spender.new(category_params)

    if @spender.save
      redirect_to @spender, notice: 'Платника успішно створено.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @spender.update(spender_params)
      redirect_to @spender, notice: 'Платника успішно оновлено.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @spender.destroy
    redirect_to spenders_path, notice: 'Платника успішно видалено.'
  end

  private
    def set_spender
      @spender = Spender.find(params[:id])
    end

    def spender_params
      params.require(:spender).permit(:name)
    end
end