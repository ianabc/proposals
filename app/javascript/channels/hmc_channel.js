import consumer from "./consumer"
import toastr from 'toastr'

consumer.subscriptions.create("HmcChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    if ( typeof data["success"] === "undefined" ){
      $.each(data["alert"], function(index, error) {
        toastr.error(error)
      })
    }
    else {
      toastr.success(data["success"])
    }
  }
});
