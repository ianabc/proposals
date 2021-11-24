class SubjectsController < ApplicationController
  before_action :set_subject_category
  before_action :set_subject, only: %i[edit update destroy]

  def edit; end

  def update
    if @subject.update(subject_params)
      redirect_to subject_category_url(@subject_category),
                  notice: 'Subject was successfully updated'
    else
      redirect_to edit_subject_category_subject_path(@subject_category, @subject),
                  status: :unprocessable_entity,
                  alert: "Unable to update subject."
    end
  end

  def destroy
    subject = @subject.subject_area_categories.find_by(subject_category_id: @subject_category.id)
    subject.destroy
    redirect_to subject_category_url(@subject_category),
                notice: 'Subject was successfully deleted.'
  end

  private

  def set_subject_category
    @subject_category = SubjectCategory.find_by(id: params[:subject_category_id])
  end

  def set_subject
    @subject = Subject.find_by(id: params[:id])
  end

  def subject_params
    params.require(:subject).permit(:code, :title)
  end
end
