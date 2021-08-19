module EmailTemplatesHelper
  def types_of_email
    EmailTemplate.email_types.map { |k, _v| [k.split('_').first.capitalize, k] }
  end

  def name_of_templates
    EmailTemplate.all.map do |template|
      email_type = template.email_type.split('_').first.capitalize
      "#{email_type}: #{template.title}"
    end
  end
end
