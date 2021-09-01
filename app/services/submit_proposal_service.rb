class SubmitProposalService
  attr_reader :params, :proposal, :proposal_form, :errors

  def initialize(proposal, params)
    @proposal = proposal
    @proposal_form = proposal.proposal_form
    @params = params
    @errors = []
  end

  def save_answers
    ids = proposal_form.proposal_fields.pluck(:id)
    ids.each do |id|
      value = params[id.to_s]

      create_or_update(id, value)
    end
    proposal_locations
  end

  def has_errors?
    unless @proposal.valid?
      @errors << @proposal.errors.full_messages
    end

    !errors.flatten.empty?
  end

  def error_messages
    errors.uniq.flatten.join(', ')
  end

  def is_final?
    params[:commit] == 'Submit Proposal'
  end


  private

  def create_or_update(id, value)
    check_field_validations(id)

    answer = Answer.find_by(proposal_field_id: id, proposal: proposal)
    if answer
      answer.update(answer: value)
    else
      Answer.create(answer: value, proposal: proposal, proposal_field_id: id)
    end
  end

  def proposal_locations
    proposal.locations = Location.where(id: params[:location_ids])
  end

  def check_field_validations(id)
    if @errors.flatten.count.zero?
      field = ProposalField.find(id)
      if field.location_id
        return unless @proposal.locations.include?(field.location)
      end

      @errors << ProposalFieldValidationsService.new(field, proposal).validations
    end
  end
end
