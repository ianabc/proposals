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

  private

  def set_review
    @review = Review.find_by(id: params[:id])
  end
end
