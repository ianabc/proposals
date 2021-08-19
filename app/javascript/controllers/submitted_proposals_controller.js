import { Controller } from "stimulus"
import Rails from '@rails/ujs'

export default class extends Controller {
  static targets = [ "template" ]

  editFlow() {
    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    let data = new FormData()
    data.append("ids", array)
    var url = `/submitted_proposals/edit_flow`
    Rails.ajax({
      url,
      type: "POST",
      data
    })
  }

  emailTemplate() {
    let value = event.currentTarget.value
    if(value) {
      let data = new FormData()
      data.append("email_template", value)
      var url = `/emails/email_template`
      Rails.ajax({
        url,
        type: "PATCH",
        data,
        success: (data) => {
          $('#subject').val(data.email_template.subject)
          $('#body').val(data.email_template.body)
        }
      })
    }else {
      $('#subject').val('')
      $('#body').val('')
    }
  }
}
