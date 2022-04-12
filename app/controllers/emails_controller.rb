class EmailsController < ApplicationController
  load_and_authorize_resource
  before_action :set_organizer_emails, only: %i[email_types]

  def new
    @email_templates = EmailTemplate.all
    @email = Email.new
    @proposal = Proposal.find(params[:id])
  end

  def email_template
    template = params[:email_template]
    email_type = find_email_type(template)
    email_type += "_type"
    @email_template = EmailTemplate.find_by(email_type: email_type, title: template.split(': ').last)
    render json: { email_template: @email_template }, status: :ok
  end

  def email_types
    email_templates = []
    email_templates << EmailTemplate.where(email_type: %w[approval_type reject_type decision_email_type])
    templates = []
    templates = make_templates(email_templates, templates) if email_templates
    render json: { email_templates: templates, emails: @organizer_emails }, status: :ok
  end

  private

  def make_templates(email_templates, templates)
    email_templates.flatten.each do |template|
      email_type = template.email_type.split('_').first.capitalize
      email_type += ' Email' if email_type == 'Decision'
      templates << "#{email_type}: #{template.title}"
    end
    templates
  end

  def find_email_type(template)
    email_type = template.split(': ').first.downcase
    email_type = email_type.split.join('_') if email_type == 'decision email'
    email_type = email_type.split.join('_') if email_type == 'revision'
    email_type = email_type.split.join('_') if email_type == 'revision spc'
    email_type
  end

  def set_organizer_emails
    proposals = Proposal.where(id: params[:ids])
    organizer_emails = Invite.where(proposal_id: params[:ids], invited_as: 'Organizer',
                                    status: :confirmed).pluck(:email)
    @organizer_emails = proposals.map(&:lead_organizer).pluck(:email) + organizer_emails
  end
end
