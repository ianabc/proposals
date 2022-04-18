class EmailTemplatesController < ApplicationController
  load_and_authorize_resource
  before_action :set_template, only: %i[show edit update destroy]

  def index
    @email_templates = EmailTemplate.all
  end

  def new
    @email_template = EmailTemplate.new
  end

  def create
    @email_template = EmailTemplate.new(email_template_params)
    if @email_template.save
      redirect_to email_templates_path, notice: t('email_templates.create.success')
    else
      redirect_to new_email_template_path(@email_template), alert: @email_template.errors.full_messages
    end
  end

  def show; end

  def edit; end

  def update
    if @email_template.update(email_template_params)
      redirect_to email_templates_path, notice: t('email_templates.update.success')
    else
      redirect_to edit_email_template_path(@email_template), alert: @email_template.errors.full_messages
    end
  end

  def destroy
    @email_template.destroy
    redirect_to email_templates_path, notice: t('email_templates.destroy.success')
  end

  private

  def email_template_params
    params.require(:email_template).permit(:email_type, :title, :subject, :body)
  end

  def set_template
    @email_template = EmailTemplate.find_by(id: params[:id])
  end
end
