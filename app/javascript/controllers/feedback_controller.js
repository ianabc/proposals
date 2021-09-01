import { Controller } from "stimulus"
import Rails from '@rails/ujs'

export default class extends Controller {

  static targets = [ "reply", "container" ]

  update() {
    var feedbackId = event.target.dataset.value
    let data = new FormData()
    data.append("id", feedbackId)
    var url = "/feedback/" + feedbackId
    Rails.ajax({
      url,
      type: "PATCH",
      data
    })
  }

  showCollapsable() {
    var collapsable = event.target.dataset.id
    var id = "#" + collapsable
    if($(id).hasClass('show')) {
      $(id).collapse("hide")
    } else {
      $(id).collapse("show")
    }
  }

  addReply() {
    let _this = this
    var feedbackId = event.target.dataset.id
    var reply = this.replyTarget.value
    let data = new FormData()
    data.append("id", feedbackId)
    data.append("feedback_reply", reply)
    var url = "/feedback/" + feedbackId + "/add_reply"
    Rails.ajax({
      url,
      type: "PATCH",
      data,
      success() {
        toastr.success('Your reply has been added.')
        _this.containerTarget.remove();

      },
      error() {
        toastr.error('Your reply could not be added.')
      },
    })
  }
}
