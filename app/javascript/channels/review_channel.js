import consumer from "./consumer"

if (document.querySelector('meta[name=action-cable-url]')) {
  consumer.subscriptions.create("ReviewChannel", {
    connected() {
    },

    disconnected() {
    },

    received(data) {
      $(".reviews-booklet-btn").html("Create Reviews Booklet")
      $(".reviews-booklet-btn").removeClass("disabled");
      $(".reviews-booklet-ok-btn").removeClass("disabled");
      if ( typeof data["success"] === "undefined" ){
        toastr.error(data["alert"])
      }
      else {
        document.getElementById("reviews_booklet").click();
        toastr.success(data["success"])
      }
    }
  });
}
