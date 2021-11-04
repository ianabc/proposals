module EmailTemplatesHelper
  def types_of_email
    EmailTemplate.email_types.map do |k, _v|
      [
        case k&.split('_')&.first&.capitalize
        when 'Revision'
          arr = k.split("_")
          if arr[1] == 'spc'
            "#{k&.split('_')&.first&.capitalize} SPC"
          else
            k&.split('_')&.first&.capitalize
          end
        when 'Decision'
          "#{k&.split('_')&.first&.capitalize} Email"
        when 'Organizer' || 'Participant'
          "#{k&.split('_')&.first&.capitalize} Invitation"
        else
          k&.split('_')&.first&.capitalize
        end, k
      ]
    end
  end

  def name_of_templates
    templates = EmailTemplate.all.map do |template|
      email_type = template.email_type.split('_').first.capitalize
      case email_type
      when 'Revision'
        arr = template.email_type.split('_')
        if arr[1] == 'spc'
          "#{email_type} SPC: #{template&.title}"
        else
          "#{email_type}: #{template&.title}"
        end
      when 'Decision'
        "#{email_type} Email: #{template&.title}"
      when 'Organizer' || 'Participant'
        next
      else
        "#{email_type}: #{template&.title}"
      end
    end

    templates.compact
  end
end
