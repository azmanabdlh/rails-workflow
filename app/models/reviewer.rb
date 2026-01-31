class Reviewer < ApplicationRecord
  belongs_to :workflow
  belongs_to :user

  enum :phase, {
    pending: 1,
    cancelled: 2,
    passed: 3
  }


  def reviewable_by?(user)
    user.id == user_id
  end

  def mark(phase, **options)
    update(
      phase: phase,
      decided_at: Time.current,
      **options
    )
  end
end
