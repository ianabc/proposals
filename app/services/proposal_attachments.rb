# methods for handling attachments to proposals
module ProposalAttachments

  def proposal_attachments(proposal, text, file_errors)
    text ||= ''
    proposal.files&.each_with_index do |file, num|
      text << "\n\\newpage\n\\thispagestyle{empty}\n"

      filename = file.filename.to_s.tr('_', '-')
      file_path = ActiveStorage::Blob.service.send(:path_for, file.key)
      full_filename = write_attachment_file(File.read(file_path), filename, proposal)

      text << supplementary_file_tex(num, filename, full_filename)
    rescue StandardError
      file_errors ||= []
      file_errors << filename
      next
    end

    [text, file_errors]
  end

  def supplementary_file_tex(num, filename, full_filename)
    # scale first page 0.8 to avoid the page content overlapping the heading
    tex = "\\includepdf[scale=0.8,pages=1,pagecommand={\\subsection*
           {File Attachment #{num += 1}: #{filename}}}]{#{full_filename}}\n"

    # Only include the subsection heading on the 1st page of the attached file
    if PDF::Reader.new(full_filename).page_count > 1
      tex << "\\includepdf[scale=1,pages=2-,pagecommand={
              \\thispagestyle{empty}}]{#{full_filename}}\n"
    end

    tex
  end

  def write_attachment_file(file_content, filename, proposal)
    full_path_filename = "#{Rails.root}/tmp/#{proposal&.code}-#{filename}"
    File.binwrite(full_path_filename, file_content)
    full_path_filename
  end
end
