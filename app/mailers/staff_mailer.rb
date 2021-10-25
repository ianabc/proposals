# Notification messages to Staff
class StaffMailer < ApplicationMailer

  def review_file_problems
    to_email = params[:staff_email]
    errors = params[:errors]
    @body = "The proposal reviews you selected had some files that are
              incompatible with the Proposals software. They will need to be
              re-uploaded to EditFlow as PDF files of the same
              name.\n\n".squish
    @body << "Problem files:\n"

    errors.each do |error|
      @body << "* #{error}"
    end

    mail(to: to_email, subject: "BIRS Proposal Reviews file problems")
  end
end
