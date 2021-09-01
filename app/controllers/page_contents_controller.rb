class PageContentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_guideline, only: %i[edit update]

  def edit; end

  def update
    redirect_to guidelines_path, notice: "Guidelines was successfully updated" if @guideline.update(page_params)
  end

  private

  def set_guideline
    @guideline = PageContent.find(params[:id])
  end

  def page_params
    params.require(:page_content).permit(:guideline)
  end
end
