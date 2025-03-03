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
      document.getElementById("proposal_booklet").click();
      toastr.success(data["success"])
    }
  }
});
