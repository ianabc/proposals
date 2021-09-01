import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['province','state','otherAcademicStatus', 'otherOption', 'countryOption']

  connect() {
    if(this.otherOptionTarget.value || this.countryOptionTarget.value) {
      this.handleAcademicOptions(this.otherOptionTarget.value)
      this.handleCountryOptions(this.countryOptionTarget.value)
    }
  }

  handleCountryOptions(targetValue) {
    if(event.currentTarget.value === 'Canada' || targetValue === 'Canada') {
      this.stateTarget.classList.add("hidden")
      this.provinceTarget.classList.remove("hidden")
    } 
    else if(event.currentTarget.value === 'United States of America' || targetValue === 'United States of America') {
      this.stateTarget.classList.remove("hidden")
      this.provinceTarget.classList.add("hidden")

    }else{
      this.stateTarget.classList.add("hidden")
      this.provinceTarget.classList.add("hidden")
    }
  }

  handleAcademicOptions(targetValue) {
   if(event.currentTarget.value === 'Other' || targetValue === 'Other') {
    this.otherAcademicStatusTarget.classList.remove("hidden")
   } else {
     this.otherAcademicStatusTarget.classList.add("hidden")
   }
  }
}
