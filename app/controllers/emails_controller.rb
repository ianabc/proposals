class EmailsController < ApplicationController
  load_and_authorize_resource

  def new
    @email_templates = EmailTemplate.all
    @email = Email.new
  end

  def email_template
    template = params[:email_template]
    email_type = template.split(': ').first.downcase
    email_type += "_type"
    @email_template = EmailTemplate.find_by(email_type: email_type, title: template.split(': ').last)
    render json: { email_template: @email_template }, status: :ok
  end
end
