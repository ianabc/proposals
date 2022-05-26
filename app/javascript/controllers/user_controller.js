import { end } from "@popperjs/core";
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["field", "error", "btn"]

  connect() {
      this.validate()
  }

  validate (){
    let emailAddress = this.fieldTarget.value
    let regexEmail = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;

    if (emailAddress.match(regexEmail) || emailAddress.length < 1) {
        this.btnTarget.disabled = false
        this.errorTarget.textContent = "";
        
    } else {
        this.errorTarget.textContent = "Please enter a valid email"
        this.btnTarget.disabled = true
    }
  }
}
