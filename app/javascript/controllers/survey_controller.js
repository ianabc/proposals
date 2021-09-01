import { Controller } from "stimulus"

export default class extends Controller {
  
  static targets = ['citizenship', 'otherCitizenship', 'ethnicity', 'otherEthnicity',
                   'gender', 'otherGender', 'indigenous', 'indigenousYes', 'disability']

  connect() {
    if(this.citizenshipTarget.value) {
      this.handleCitizenshipOptions(this.citizenshipTarget.value)
    }
    if(this.ethnicityTarget.value) {
      this.handleEthnicityOptions(this.ethnicityTarget.value)
    }
    if(this.genderTarget.value) {
      this.handleGenderOptions(this.genderTarget.value)
    }
    if(this.indigenousTarget.value) {
      this.handleIndigenousOptions(this.indigenousTarget.value)
    }
  }
  
  handleCitizenshipOptions(targetValue) {
    if (this.citizenshipTarget.value === 'Other' || targetValue === 'Other') {
      this.otherCitizenshipTarget.classList.remove("hidden")
      $("#citizenship_other").prop('required', true);
    } else {
      this.otherCitizenshipTarget.classList.add("hidden")
      $("#citizenship_other").hide();
    }
  }

  handleEthnicityOptions(targetValue) {
    if (this.ethnicityTarget.value === 'Other' || targetValue === 'Other') {
      this.otherEthnicityTarget.classList.remove("hidden")
      $("#ethnicity_other").prop('required', true);
    } else {
      this.otherEthnicityTarget.classList.add("hidden")
      $("#ethnicity_other").hide();
    }
  }

  handleGenderOptions(targetValue) {
    if (this.genderTarget.value === 'Other' || targetValue === 'Other') {
      this.otherGenderTarget.classList.remove("hidden")
      $("#gender_other").prop('required', true);
    } else {
      this.otherGenderTarget.classList.add("hidden")
      $("#gender_other").hide();
    }
  }

  handleIndigenousOptions(targetValue) {
    if (this.indigenousTarget.value === 'Yes' || targetValue === 'Yes') {
      this.indigenousYesTarget.classList.remove("hidden")
      $("#indigenous_person_yes").prop('required', true);
    } else {
      this.indigenousYesTarget.classList.add("hidden")
      $("#indigenous_person_yes").hide();
    }
  }

  handleDisabilityOptions() {
    if(this.disabilityTarget.value === 'Yes' || this.disabilityTarget.value === 'Prefer') {
      alert('BIRS is committed to providing an experience that is accessible to all attendees. If you would like to discuss accommodations that could enhance your time with BIRS, please contact the BIRS Program Coordinator at birs@birs.ca.')
    }
  }
}

