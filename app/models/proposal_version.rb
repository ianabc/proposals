class ProposalVersion < ApplicationRecord
  belongs_to :proposal

  default_scope { order(version: :desc) }

  enum status: {
    draft: 0,
    submitted: 1,
    initial_review: 2,
    revision_requested_before_review: 3,
    revision_submitted: 4,
    in_progress: 5,
    decision_pending: 6,
    decision_email_sent: 7,
    approved: 8,
    declined: 9,
    revision_requested_spc: 10,
    revision_submitted_spc: 11,
    in_progress_spc: 12,
    shortlisted: 13
  }
end
