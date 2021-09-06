import { Controller } from "stimulus"
import Rails from '@rails/ujs'
import toastr from 'toastr'

export default class extends Controller {
  static targets = [ "templates" ]

  editFlow() {
    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let data = new FormData()
      data.append("ids", array)
      var url = `/submitted_proposals/edit_flow`
      Rails.ajax({
        url,
        type: "POST",
        data
      })
    }
  }

  emailTemplate() {
    let value = event.currentTarget.value
    if(value) {
      let data = new FormData()
      data.append("email_template", value)
      var url = `/emails/email_template`
      Rails.ajax({
        url,
        type: "PATCH",
        data,
        success: (data) => {
          $('#subject').val(data.email_template.subject)
          $('#body').val(data.email_template.body)
        }
      })
    }else {
      $('#subject').val('')
      $('#body').val('')
    }
  }

  emailModal() {
    event.preventDefault()

    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let id = event.currentTarget.id
      let _this = this
      $.post(`/emails/email_types?type=${id}`, function(data) {
        const selectBox = _this.templatesTarget;
        selectBox.innerHTML = '';
        const opt = document.createElement('option');
        opt.innerHTML = ''
        selectBox.appendChild(opt);
        data.email_templates.forEach((item) => {
          const opt = document.createElement('option');
          opt.innerText = item
          selectBox.appendChild(opt);
        });
        $("#email-template").modal('show')
      })
    }
  }

  sendEmails(event) {
    event.preventDefault();

    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    let length = array.length
    if(typeof array [`${length}`] === "undefined" && typeof array [`${length - 1}`] === "undefined") {
      array = array.slice(0, length-2)
    }
    else if(length > 1 && typeof array [`${length - 1}`] === "undefined") {
      array = array.slice(0, length-1)
    }
    if(this.templatesTarget.value) {
      $.post(`/submitted_proposals/approve_decline_proposals?proposal_ids=${array}`,
        $("#approve_decline_proposals").serialize(), function() {
          toastr.success("Emails have been sent!")
          setTimeout(function() {
            window.location.reload();
          }, 2000)
        }
      )
      .fail(function(response) {
        let errors = response.responseJSON
        $.each(errors, function(index, error) {
          toastr.error(error)
        })
      });
    }
    else {
      toastr.error("Please select any template")
    }
  }
}
