class FaqsController < ApplicationController
  load_and_authorize_resource
  before_action :set_faq, only: %i[edit update destroy move]

  def index
    @faqs = Faq.all
  end

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to faqs_path, notice: t('faqs.create.success')
    else
      render :new, alert: t('faqs.create.failure')
    end
  end

  def edit; end

  def update
    if @faq.update(faq_params)
      redirect_to faqs_path, notice: t('faqs.update.success')
    else
      redirect_to faqs_path, alert: @faq.errors.full_messages.join(' ,')
    end
  end

  def destroy
    redirect_to faqs_path, notice: t('faqs.destroy.success') if @faq.destroy
  end

  def move
    @faq.update(position: params[:position].to_i)
    render json: "Position updated!", status: :ok
  end

  private

  def set_faq
    @faq = Faq.find_by(id: params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer)
  end
end
