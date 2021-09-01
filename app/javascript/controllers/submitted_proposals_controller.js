import { Controller } from "stimulus"
import Rails from '@rails/ujs'
import toastr from 'toastr'

export default class extends Controller {
  static targets = [ "toc", "ntoc" ]

  connect () {
    this.tocTarget.checked = true;
  }

  editFlow() {
    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    let data = new FormData()
    data.append("ids", array)
    var url = `/submitted_proposals/edit_flow`
    Rails.ajax({
      url,
      type: "POST",
      data
    })
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

  tableOfContent() {
    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      $.post(`/submitted_proposals/table_of_content?proposals=${array}`,
        $('form#submitted-proposal').serialize(), function(data) {
          $('#proposals').text(data.proposals)
          $("#table-window").modal('show')
        }
      )
    }
  }

  booklet() {
    let ids = $('#proposals').text().slice(1)
    let table = ''
    if(this.tocTarget.checked) {
      table = "toc"
    }
    else {
      table = "ntoc"
    }
    if(table !== '') {
      $.post(`/submitted_proposals/proposals_booklet?proposal_ids=${ids}&table=${table}`,
        function() {
          document.getElementById("booklet").click();
          window.location.reload()
      })
    }
  }
}
