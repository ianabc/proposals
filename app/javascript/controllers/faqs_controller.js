import { Controller } from "stimulus"

export default class extends Controller {
  copy(event) {
    var input = document.createElement("INPUT");
    input.setAttribute("type", "text");
    input.setAttribute("value", event.currentTarget.href)
    document.body.append(input)
    input.select()
    document.execCommand("copy")
  }
}
