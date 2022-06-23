class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_feedback, only: %w[update add_reply]

  def index
    @feedback = Feedback.all
  end

  def new
    @feedback = Feedback.new
    @proposals = current_user.person.proposals
  end

  def create # rubocop:disable Metrics/AbcSize
    @feedback = Feedback.new(feedback_params)
    @proposals = current_user.person.proposals
    @feedback.user = current_user
    if @feedback.save
      FeedbackMailer.with(feedback: @feedback).new_feedback_email(@feedback.proposal_id).deliver_later
      redirect_to feedbacks_path, notice: t('feedback.create.success')
    else
      render :new, alert: "Error: #{@feedback.errors.full_messages}"
    end
  end

  def update
    raise CanCan::AccessDenied unless can? :manage, @feedback

    @feedback.toggle(:reviewed)
    redirect_to feedback_path
  end

  def add_reply
    raise CanCan::AccessDenied unless can? :manage, @feedback

    if @feedback.update(reply: params[:feedback_reply])
      FeedbackMailer.with(feedback: @feedback).feedback_reply_email(@feedback.proposal_id).deliver_later
      render json: {}, status: :ok
    else
      render json: { error: @feedback.errors.full_messages },
             status: :internal_server_error
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content, :proposal_id)
  end

  def set_feedback
    @feedback = Feedback.find_by(id: params[:id])
  end
end
