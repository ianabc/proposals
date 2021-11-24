class AmsSubjectsController < ApplicationController
  before_action :set_subject_category
  before_action :set_ams_subject, only: %i[edit update destroy]

  def edit; end

  def update
    if @ams_subject.update(ams_subject_params)
      redirect_to subject_category_url(@subject_category),
                  notice: 'AMS Subject was successfully updated'
    else
      redirect_to edit_subject_category_ams_subject_path(@subject_category,
                                                         @ams_subject),
                  status: :unprocessable_entity,
                  alert: "Unable to update AMS subject."
    end
  end

  def destroy
    ams_subject = @ams_subject.ams_subject_categories
                              .find_by(subject_category_id: @subject_category.id)
    ams_subject.destroy
    redirect_to subject_category_url(@subject_category),
                notice: 'AMS Subject was successfully deleted.'
  end

  private

  def set_subject_category
    @subject_category = SubjectCategory.find_by(id: params[:subject_category_id])
  end

  def set_ams_subject
    @ams_subject = AmsSubject.find_by(id: params[:id])
  end

  def ams_subject_params
    params.require(:ams_subject).permit(:code, :title)
  end
end
