class ProposalFieldValidationsService
  attr_reader :proposal, :field

  def initialize(field, proposal)
    @proposal = proposal
    @field = field
    @errors = []
  end

  def validations
    return unless proposal

    @answer = Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)&.answer

    check_validations(field.validations)
    @errors
  end

  def check_validations(validations)
    validations.each do |val|
      case val.validation_type
      when 'mandatory'
        if val.proposal_field.fieldable_type == 'ProposalFields::File' && attached_file
          @errors << val.error_message
        elsif !val.proposal_field.fieldable_type == 'ProposalFields::File'
          @errors << val.error_message if @answer == ""
          @errors << val.error_message unless @answer
        end
      when 'less than (integer matcher)'
        @errors << val.error_message unless @answer.to_i < val.value.to_i
      when 'less than (float matcher)'
        @errors << val.error_message unless @answer.to_f < val.value.to_f
      when 'greater than (integer matcher)'
        @errors << val.error_message unless @answer.to_i > val.value.to_i
      when 'greater than (float matcher)'
        @errors << val.error_message unless @answer.to_f > val.value.to_f
      when 'equal (string matcher)'
        @errors << val.error_message unless @answer == val.value
      when 'equal (integer matcher)'
        @errors << val.error_message unless @answer.to_i == val.value.to_i
      when 'equal (float matcher)'
        @errors << val.error_message unless @answer.to_f == val.value.to_f
      when 'words limit'
        texcount = %x{echo "#{@answer}" | texcount -total -}
        word_count = texcount.match(/Words in text: (\d+)/)[1]
        @errors << val.error_message unless word_count.to_i <= val.value.to_i
      when '5-day workshop preferred/Impossible dates'
        preferred_impossible_dates_validation
      end
    end
  end

  def preferred_impossible_dates_validation
    return unless @answer

    preferred = JSON.parse(@answer)&.first(5)
    preferred_dates = preferred.reject { |date| date == '' }
    uniq_dates = JSON.parse(@answer).reject { |date| date == '' }

    @errors << 'At least 2 preferred dates must be selected' if preferred_dates.count < 2
    @errors << "You can't select the same date twice" unless uniq_dates.uniq.count == uniq_dates.count
  end

  def attached_file
    !Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)&.file&.attached?
  end
end
