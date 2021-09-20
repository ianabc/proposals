import { Controller } from 'stimulus'
import Rails from '@rails/ujs'
import toastr from 'toastr'

export default class extends Controller {
  static targets = ['target', 'template', 'targetOne', 'templateOne']
  static values = {
    wrapperSelector: String,
    maxOrganizer: Number,
    maxParticipant: Number,
    organizer: Number,
    participant: Number
  }
 
  initialize () {
    this.wrapperSelector = this.wrapperSelectorValue || '.nested-invites-wrapper'
  }

  addOrganizers (e) {
    e.preventDefault()

    let content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    if (this.organizerValue < this.maxOrganizerValue) {
      this.targetTarget.insertAdjacentHTML('beforebegin', content)
      this.organizerValue += 1
    } else {
      toastr.error("You can't add more because the maximum number of Organizer invitations has been sent.")
    }
  }

  addParticipants (e) {
    e.preventDefault()

    let contentOne = this.templateOneTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    if (this.participantValue < this.maxParticipantValue) {
      this.targetOneTarget.insertAdjacentHTML('beforebegin', contentOne)
      this.participantValue += 1
    } else {
      toastr.error("You can't add more because the maximum number of Participant invitations has been sent.")
    }
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

  invitePreview ()  {
    event.preventDefault()

    let id = event.currentTarget.dataset.id;
    let invitedAs = event.currentTarget.id
    $.post(`/submit_proposals/invitation_template?proposal=${id}&invited_as=${invitedAs}`, function(data) {
        $('#subject').text(data.subject)
        $('#email_body_preview').html(data.body)
        $('#email_body').text(data.body)
        $("#email-preview").modal('show')
      }
    )
  }

  sendInvite () {
    let id = event.currentTarget.dataset.id;
    let invitedAs = ''
    let inviteId = 0
    let _this = this
    let inviteParticipant = event.currentTarget.dataset.participant || 0
    let inviteOrganizer = event.currentTarget.dataset.organizer || 0
    var body = $('#email_body').text()
    $.post(`/submit_proposals?proposal=${id}&create_invite=true.js`,
      $('form#submit_proposal').serialize(), function(data) {
        if (body.includes("supporting organizer")) {
          invitedAs = 'Organizer'
          inviteId = inviteOrganizer
        }
        else if (body.includes("participant")) {
          invitedAs = 'Participant'
          inviteId = inviteParticipant
        }
        _this.sendInviteEmails(id, invitedAs, inviteId, data)
      }
    ) 
    .fail(function(response) {
      let errors = response.responseJSON
      $.each(errors, function(index, error) {
        toastr.error(error)
      })
    });
  }

  sendInviteEmails(id, invitedAs, inviteId, data) {
    var url = ''
    let formData = new FormData()
    let emailBody = $('#email_body').text()
    if(data.errors.length > 0 && data.counter === 0) {
       $.each(data.errors, function(index, error) {
        toastr.error(error)
        window.stop();
      })
    }
    else if(data.errors.length > 0 && data.counter > 0) {
      $.each(data.errors, function(index, error) {
        toastr.error(error)
      })
      formData.append("body", emailBody)
      url = `/proposals/${id}/invites/${inviteId}/invite_email?invited_as=${invitedAs}`
      Rails.ajax({
        url,
        type: "POST",
        data: formData,
        success: () => {
          setTimeout(function() {
            window.location.reload();
          }, 3000)
        }
      })
    }
    else {
      formData.append("body", emailBody)
      url = `/proposals/${id}/invites/${inviteId}/invite_email?invited_as=${invitedAs}`
      Rails.ajax({
        url,
        type: "POST",
        data: formData,
        success: () => {
          toastr.success('Invitation has been sent!')
          setTimeout(function() {
            window.location.reload();
          }, 2000)
        }
      })
    }
  }
}
