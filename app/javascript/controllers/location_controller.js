import { Controller } from "stimulus"
import toastr from 'toastr'

export default class extends Controller {
  static targets = [ "excludeDates" , "startDate", "endDate" ]

  excludeDatesList() {
    let startDate = this.startDateTarget.value
    let endDate = this.endDateTarget.value
    if (startDate === "" || endDate === "") {
      return
    }
    else {
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
  }
}
