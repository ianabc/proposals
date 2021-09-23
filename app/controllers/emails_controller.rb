class EmailsController < ApplicationController
  load_and_authorize_resource

  def new
    @email_templates = EmailTemplate.all
    @email = Email.new
  end

  def email_template
    template = params[:email_template]
    email_type = template.split(': ').first.downcase
    email_type = email_type.split.join('_') if email_type == 'decision email'
    email_type += "_type"
    @email_template = EmailTemplate.find_by(email_type: email_type, title: template.split(': ').last)
    render json: { email_template: @email_template }, status: :ok
  end

  def email_types
    @email_type = "approval_type" if params[:type] == "approve"
    @email_type = "reject_type" if params[:type] == "decline"
    @email_templates = EmailTemplate.where(email_type: @email_type)
    @templates = []
    make_templates
    render json: { email_templates: @templates }, status: :ok
  end

  private

  def make_templates
    @email_templates.each do |template|
      @email_type = template.email_type.split('_').first.capitalize
      @templates << if @email_type == 'Decision'
                      "#{@email_type} Email: #{template.title}"
                    else
                      "#{@email_type}: #{template.title}"
                    end
    end
  end
end
