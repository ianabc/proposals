# methods for handling attachments to proposals
module LatexAttachments

  def add_proposal_attachments(proposal, text, file_errors)
    text ||= ''
    proposal.files&.each_with_index do |file, num|
      text << "\n\\newpage\n\\thispagestyle{empty}\n"

      filename = file.filename.to_s.tr('_', '-')
      file_path = ActiveStorage::Blob.service.send(:path_for, file.key)
      full_filename = write_attachment_file(File.read(file_path), filename, proposal)

      text << add_file_to_tex(num, filename, full_filename)
    rescue StandardError
      file_errors ||= []
      file_errors << filename
      next
    end

    [text, file_errors]
  end

  def add_review_attachments(review, text, proposal, file_errors)
    file_errors ||= []
    text ||= ''

    review.files.each_with_index do |file, num|
      filename = file.filename.to_s.tr('_', '-')
      file_extension = filename.split('.').last.downcase
      file_path = ActiveStorage::Blob.service.send(:path_for, file.key)
      unless File.exist?(file_path)
        file_errors << "File missing: #{filename}"
        next
      end

      if file_extension == 'txt' || file_extension == 'text'
        text_content = LatexToPdf.escape_latex(File.read(file_path))
        text << "\\noindent File Attachment #{num += 1}: #{text_content} \n\n\n"
      elsif file_extension == 'pdf'
        full_filename = write_attachment_file(File.read(file_path), filename,
                                              proposal)
        text << add_file_to_tex(num, filename, full_filename)
      else
        # warn user of non-pdf file
        file_errors << "Non-PDF file: #{filename}"
      end
    end

    [text, file_errors]
  end

  def add_file_to_tex(num, filename, full_filename)
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
