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
