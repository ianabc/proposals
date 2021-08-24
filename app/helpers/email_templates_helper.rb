module EmailTemplatesHelper
  def types_of_email
    EmailTemplate.email_types.map do |k, _v|
      [
        if k.split('_').first.capitalize == 'Decision'
          "#{k.split('_').first.capitalize} Email"
        else
          k.split('_').first.capitalize
        end, k
      ]
    end
  end

  def name_of_templates
    EmailTemplate.all.map do |template|
      email_type = template.email_type.split('_').first.capitalize
      if email_type == 'Decision'
        "#{email_type} Email: #{template.title}"
      else
        "#{email_type}: #{template.title}"
      end
    end
  end
end
