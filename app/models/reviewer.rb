class Reviewer < ApplicationRecord
  belongs_to :candidate_stage
  belongs_to :user

  enum :phase, {
    pending: 1,
    cancelled: 2,
    hired: 3
  }

  OUTCOME = %i[
    cancelled
    hired
  ]
end
