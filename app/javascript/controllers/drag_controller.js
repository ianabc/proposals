import { Controller } from 'stimulus'
import Sortable from "sortablejs"
import Rails from '@rails/ujs'
import toastr from 'toastr'

export default class extends Controller {
  connect(){
    this.sortable = Sortable.create(this.element, {
      onEnd: this.end.bind(this)
    })
  }

  end(event) {
    let id = event.item.dataset.id
    let data = new FormData()
    data.append("position", event.newIndex + 1)
    let url = "/faqs/" + id + "/move";
    Rails.ajax({
      url,
      type: 'PATCH',
      data,
      success: (res) => {
        toastr.success(res)
      },
      error: (err) => {
        toastr.error(err)
      }
    })
  }
}
