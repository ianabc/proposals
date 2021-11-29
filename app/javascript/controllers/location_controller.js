import { Controller } from "stimulus"
import toastr from 'toastr'

export default class extends Controller {
  static targets = [ "excludeDates" , "startDate", "endDate" ]

   connect(){
    let startDate = this.startDateTarget.value
    let endDate = this.endDateTarget.value
    let _this = this
    $.post(`/locations/weeks_exclude_dates?start=${startDate}&end=${endDate}`, function(data) {
      const selectBox = _this.excludeDatesTarget;
      selectBox.innerHTML = '';
      const opt = document.createElement('option');
      opt.innerHTML = ''
      selectBox.appendChild(opt);
      data.exclude_dates.forEach((item) => {
        const opt = document.createElement('option');
        opt.innerText = item
        selectBox.appendChild(opt);
      });
    })
   }

  excludeDatesList() {
    let startDate = this.startDateTarget.value
    let endDate = this.endDateTarget.value
    var start = new Date(startDate)
    var end = new Date(endDate)
   
    if(startDate !== "" && start.getDay() !== 0) {
      toastr.error("Start Date must be Sunday!")
      document.getElementById('location_exclude_dates').length = 0;
    }
    if(endDate !== "" && end.getDay() !== 5){
      toastr.error("End Date must be Friday!")
      document.getElementById('location_exclude_dates').length = 0;
    }
    else if (startDate === "" || endDate === "") {
      return
    }
    else if(start.getDay() === 0 && end.getDay() === 5) {
      let _this = this
      $.post(`/locations/weeks_exclude_dates?start=${startDate}&end=${endDate}`, function(data) {
        const selectBox = _this.excludeDatesTarget;
        selectBox.innerHTML = '';
        const opt = document.createElement('option');
        opt.innerHTML = ''
        selectBox.appendChild(opt);
        data.exclude_dates.forEach((item) => {
          const opt = document.createElement('option');
          opt.innerText = item
          selectBox.appendChild(opt);
        });
      })
      .fail(function(response) {
        let errors = response.responseJSON
        $.each(errors, function(index, error) {
          toastr.error(error)
        })
      });
    }
  }
}
