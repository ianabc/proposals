import { Controller } from 'stimulus'

export default class extends Controller {

  static targets = ['target', 'template']
  static values = {
    wrapperSelector: String
  }

  initialize () {
    this.wrapperSelector = this.wrapperSelectorValue || '.nested-options-wrapper'
  }

  add (e) {
    e.preventDefault()

    let content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.targetTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove (e) {
    e.preventDefault()

    let wrapper = e.target.closest(this.wrapperSelector)
    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'

      let input = wrapper.querySelector("input[name*='_destroy']")
      input.value = '1'
    }
  }
}
