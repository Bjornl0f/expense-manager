class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = current_user.categories
    
    # Пошук
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @categories = @categories.where("name LIKE ?", search_term)
    end
    
    # Сортування
    sort_column = %w[name].include?(params[:sort]) ? params[:sort] : 'name'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    @categories = @categories.order("#{sort_column} #{sort_direction}")
    
    # Пагінація
    @categories = @categories.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @category = current_user.categories.build
  end

  def edit
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      redirect_to @category, notice: t('categories.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to @category, notice: t('categories.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: t('categories.destroyed')
  end

  private
    def set_category
      @category = current_user.categories.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name)
    end
end