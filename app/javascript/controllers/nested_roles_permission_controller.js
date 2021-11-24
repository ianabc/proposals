import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'targetOne', 'templateOne' ]
  static values = { wrapperSelector: String }
 
  initialize () {
    this.wrapperSelector = this.wrapperSelectorValue || '.nested-roles-permission-wrapper'
  }

  addPermissions (e) {
    e.preventDefault()

    let contentOne = this.templateOneTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.targetOneTarget.insertAdjacentHTML('beforebegin', contentOne)
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

  usersPreview() {
    event.preventDefault()

    let id = event.currentTarget.dataset.id;
    $.post(`/roles/${id}/new_user.js`,
      $('form#role').serialize(), function() {
          $("#user-window").modal('show')
      }
    )
  }
}
