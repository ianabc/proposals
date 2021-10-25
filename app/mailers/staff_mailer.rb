# Notification messages to Staff
class StaffMailer < ApplicationMailer
  def review_file_problems
    to_email = params[:staff_email]
    errors = params[:errors]
    @body = "The Proposals software can only build a review book out of reviews
             that are in PDF or TXT format. Other files will need to be
              re-uploaded to EditFlow as PDF files of the same name.\n\n".squish
    @body << "Problem files:\n"

    errors.each do |error|
      @body << "* #{error}"
    end

    mail(to: to_email, subject: "BIRS Proposal Reviews file problems")
  end
end
