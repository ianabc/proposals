class SubjectCategoriesController < ApplicationController
  before_action :set_category, only: %i[show edit update destroy]

  def index
    @subject_categories = SubjectCategory.all
  end

  def new
    @subject_category = SubjectCategory.new
  end

  def create
    @subject_category = SubjectCategory.new(subject_category_params)

    if @subject_category.save
      redirect_to subject_categories_path, notice: 'Subject Category successfully created'
    else
      redirect_to new_subject_category_path(@subject_category), alert: @subject_category.errors.full_messages
    end
  end

  def show; end

  def edit; end

  def update
    if @subject_category.update(subject_category_params)
      redirect_to subject_categories_path, notice: 'Subject Category successfully updated'
    else
      redirect_to edit_subject_category_path(@subject_category), alert: @subject_category.errors.full_messages
    end
  end

  def destroy
    @subject_category.destroy
    redirect_to subject_categories_path
  end

  private

  def subject_category_params
    params.require(:subject_category).permit(:name, :code, ams_subject_ids: [], subject_ids: [])
  end

  def set_category
    @subject_category = SubjectCategory.find_by(id: params[:id])
  end
end
