class ReviewsController < ApplicationController
  before_action :set_review

  def remove_file
    file = @review.files.where(id: params[:attachment_id])
    if file.purge_later
      render json: {}, status: :ok
    else
      render json: @review.file.errors.full_messages, status: :internal_server_error
    end
  end

  def add_file
    file = params[:file]
    if @review.file_type(file)
      @review.files.attach(file)
      render json: {}, status: :ok
    else
      render json: { errors: "File format not supported" }, status: :bad_request
    end
  end

  private

  def set_review
    @review = Review.find_by(id: params[:id])
  end
end
