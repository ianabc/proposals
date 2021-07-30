$(document).ready(function() {
  $(document).on('hide.bs.modal', '#email-preview', function() {
    window.location.reload()
  });

  $('.latex-show-more').click(function() {
    var $this = $(this);
    $this.toggleClass('latex-show-more');
    if($this.hasClass('latex-show-more')) {
      $this.text('Show full error log');
    } else {
      $this.text('Hide full error log');
    }
  });

  $('[id^="chartjs"]').each(function(index) {
    this.style.height = '200px'
  })

  $('#add-more-participant, #add-more-organizer').click();
});
