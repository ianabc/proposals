import consumer from "./consumer"
import toastr from 'toastr'

consumer.subscriptions.create("ImportChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    $(".import-reviews-btn").html("Import Reviews")
    $(".import-reviews-btn").removeClass("disabled");
    if ( typeof data["success"] === "undefined" ){
      this.showErrorMessage(data)
    }
    else {
      toastr.success(data["success"])
    }
  },

  showErrorMessage(data) {
    if( data["alert"]["errors"] === null || data["alert"]["errors"] === "" ) {
      toastr.error(data["alert"]["message"])
    }
    else if( data["alert"]["message"] === null || data["alert"]["message"] === "" ) {
      toastr.error(data["alert"]["errors"])
    }
    else {
      toastr.error(data["alert"]["message"])
      toastr.error(data["alert"]["errors"])
    }
  }
});
