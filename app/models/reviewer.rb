class Reviewer < ApplicationRecord
  belongs_to :candidate_stage
  belongs_to :user

  enum :phase, {
    pending: 1,
    cancelled: 2,
    hired: 3
  }


  def reviewable_by?(user)
    user.id == user_id
  end

  def mark!(phase, **options)
    raise "unknown phase #{phase}" unless phases.key?(phase)

    update!(
      phase: phase,
      decided_at: Time.current,
      **options
    )
  end
end
