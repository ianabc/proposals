module SubjectsHelper
  def subjects_area
    Subject.order(:title).map { |sub| [sub.title, sub.id] }
  end

  def ams_subjects_code
    AmsSubject.order(:title).map { |sub| [sub.title, sub.id] }
  end

  def ams_subject_title(ams_subject)
    ams_subject.title.remove(ams_subject.title.split.first)
  end
end
