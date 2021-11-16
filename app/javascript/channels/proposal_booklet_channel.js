import consumer from "./consumer"
import toastr from 'toastr'

consumer.subscriptions.create("ProposalBookletChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    $(".proposal-booklet-btn").html("Create Booklet")
    $(".proposal-booklet-btn").removeClass("disabled");
    $(".proposal-booklet-ok-btn").removeClass("disabled");
    if ( typeof data["success"] === "undefined" ){
      toastr.error(data["alert"])
    }
    else {
      $(".download-button").removeClass("disabled")
      toastr.success(data["success"])
    }
  }
});
