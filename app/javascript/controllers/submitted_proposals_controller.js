import { Controller } from "stimulus"
import Rails from '@rails/ujs'
import toastr from 'toastr'
import Tagify from '@yaireo/tagify'

export default class extends Controller {
  static targets = [ 'toc', 'ntoc', 'templates', 'status', 'statusOptions', 'proposalStatus',
                     'organizersEmail', 'bothReviews', 'scientificReviews', 'ediReviews',
                     'reviewToc', 'reviewNToc' ]

  connect () {
    let proposalId = 0
    if (this.hasOrganizersEmailTarget) {
      var inputElm = this.organizersEmailTarget,
      tagify = new Tagify (inputElm);
    }
  }

  editFlow() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let data = new FormData()
      data.append("ids", proposalIds)
      var url = `/submitted_proposals/edit_flow`
      Rails.ajax({
        url,
        type: "POST",
        data,
        error: (response) => {
          let errors = response.errors
          toastr.error(errors)
        }
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
          $('#birs_email_subject').val(data.email_template.subject)
          tinyMCE.activeEditor.setContent(data.email_template.body)
        }
      })
    }else {
      $('#birs_email_subject').val('')
      tinyMCE.activeEditor.setContent('')
    }
  }

  emailModal() {
    event.preventDefault()

    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
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

    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(this.templatesTarget.value) {
      $('#birs_email_body').val(tinyMCE.get('birs_email_body').getContent())
      $.post(`/submitted_proposals/approve_decline_proposals?proposal_ids=${proposalIds}`,
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

  tableOfContent() {
    if(this.hasTocTarget) {
      this.tocTarget.checked = true;
    }
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      $.post(`/submitted_proposals/table_of_content?proposals=${proposalIds}`,
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
      document.getElementById('spinner').classList.add("active")
      $.post(`/submitted_proposals/proposals_booklet?proposal_ids=${ids}&table=${table}`,
        function() {
          document.getElementById("proposal_booklet").click();
          toastr.success('Proposals book successfully created.')
      }).fail(function() {
        toastr.error('Something went wrong.')
      })
      .always(function() {
        document.getElementById('spinner').classList.remove("active")
      })
    }
  }

  handleStatus() {
    let currentProposalId = event.currentTarget.dataset.id
    for(var i = 0; i < this.statusOptionsTargets.length; i++){
      if(currentProposalId === this.statusOptionsTargets [`${i}`].dataset.id){
        this.proposalStatusTargets [`${i}`].classList.add("hidden")
        this.statusOptionsTargets [`${i}`].classList.remove("hidden")
      }
    }
  }

  proposalStatuses() {
    let id = event.currentTarget.dataset.id
    let status = ''
    let _this = this
    for(var i = 0; i < this.statusTargets.length; i++){
      if(id === this.statusTargets [`${i}`].dataset.id){
        status = this.statusTargets [`${i}`].value
        $.post(`/submitted_proposals/${id}/update_status?status=${status}`, function() {
          toastr.success('Proposal status has been updated!')
          setTimeout(function() {
            window.location.reload();
          }, 1000)
        })
        .fail(function(res) {
          res.responseJSON.forEach((msg) => toastr.error(msg))
        });
      }
    }
  }

  storeID() {
    this.proposalId = event.currentTarget.dataset.value
  }

  selectAllProposals() {
    let getId = ''
    $("input:checkbox").each(function(){
      getId = document.getElementById(this.id)
      getId.checked = true
    });
  }

  unselectAllProposals() {
    let getId = ''
    $("input:checkbox").each(function(){
      getId = document.getElementById(this.id)
      getId.checked = false
    });
  }

  invertSelectedProposals() {
    let checkbox = ''
    $("input:checkbox").each(function(){
      checkbox = document.getElementById(this.id)
      if(checkbox.checked) {
        checkbox.checked = false
      } else {
        checkbox.checked = true
      }
    });
  }

  downloadCSV() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      window.location = `/submitted_proposals/download_csv.csv?ids=${selectedProposals}`
    }
  }

  importReviews() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      $.post(`/submitted_proposals/import_reviews?proposals=${proposalIds}`, function(response) {
        let res = JSON.parse(response)
        if(res.type === "alert") {
          toastr.error(res.message)
        }
        else{
          toastr.success(res.message)
          setTimeout(function() {
            window.location.reload();
          }, 1000)
        }
      }).fail(function(response) {
        toastr.error(response.responseText)
      })
    }
  }

  reviewsContent() {
    if(this.hasBothReviewsTarget && this.hasReviewTocTarget) {
      this.bothReviewsTarget.checked = true;
      this.reviewTocTarget.checked = true;
    }
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      $("#review-window").modal('show')
    }
  }

  reviewsBooklet() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    this.checkReviewType(proposalIds)
  }

  checkReviewType(proposalIds) {
    let reviewContentType = ''
    if(this.bothReviewsTarget.checked) {
      reviewContentType = "both"
    }
    else if(this.scientificReviewsTarget.checked) {
      reviewContentType = "scientific"
    }
    else {
      reviewContentType = "edi"
    }
    this.checkTableContentType(reviewContentType, proposalIds)
  }

  checkTableContentType(reviewContentType, proposalIds) {
    let table = ''
    if(this.reviewTocTarget.checked) {
      table = "toc"
    }
    else {
      table = "ntoc"
    }
    this.createReviewsBooklet(reviewContentType, proposalIds, table)
  }

  createReviewsBooklet(reviewContentType, proposalIds, table) {
    if(reviewContentType !== '') {
      document.getElementById('spinner').classList.add("active")

      $.ajax({
        url: `/submitted_proposals/reviews_booklet`,
        type: 'POST',
        data: {
          'proposals': proposalIds,
          table,
          reviewContentType
        },
        success: () => {
          document.getElementById("reviews_booklet").click();
          toastr.success('Review Booklet successfully created.')
        },
        error: () => {
          toastr.error('Something went wrong.')
        },
        complete: () => {
          document.getElementById('spinner').classList.remove("active")
        }
      })
    }
    else {
      toastr.error('Something went wrong.')
    }
  }

  removeFile(evt) {
    let dataset = evt.currentTarget.dataset
    
    $.ajax({
      url: `/reviews/${dataset.reviewId}/remove_file?attachment_id=${dataset.attachmentId}`,
      type: 'DELETE',
      data: {
        'attachment_id': dataset.attachmentId
      },
      success: () => {
        $(`#review-file${dataset.attachmentId}`).remove()
        toastr.success('Comment has successfully been removed.')
      },
      error: () => {
        toastr.error('Something went wrong.')
      }
    })
  }

  addFile(evt) {
    let dataset = evt.currentTarget.dataset
    if(evt.target.files) {
      var data = new FormData()
      var f = evt.target.files[0]
      var ext = f.name.split('.').pop();
      this.sendRequest(ext, data, f, dataset)
    }
  }

  reviewsExcelBooklet() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      window.location = `/submitted_proposals/reviews_excel_booklet.xlsx?proposals=${proposalIds}`
    }
  }

  sendRequest(ext, data, f, dataset) {
    if( ext === "pdf" || ext === "txt" || ext === "text") {
      data.append("file", f)
      var url = `/reviews/${dataset.reviewId}/add_file`
      Rails.ajax({
        url,
        type: "POST",
        data,
        success: () => {
          location.reload(true)
          toastr.success('File is attached successfully.')
        },
        error: (response) => {
          toastr.error(response.errors)
        }
      })
    }
    else {
      toastr.error('Only .pdf and .txt files are allowed.')
    }
  }
}
