class CandidateStage < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers


  def can_transition_to?(to)
    return false if outcome?

    (stage.order + 1) == to.order && stage.same_post?(to)
  end

  def valid_transition_phase?(phase)
    return false if outcome?

    Reviewer.phases.key?(phase.to_s)
  end


  def reconcile(to)
    transaction do
      now = Time.current
      update!(exited_at: now)

      candidate.candidate_stages.create!(
        stage_id: to.id,
        entered_at: now
      )

      candidate.update!(current_stage_id: to.id)
    end
  end

  def decide_by!(user, phase, **options)
    reviewers.each do |r|
      r.mark!(phase, **options) if r.reviewable_by?(user)
    end
  end

  def outcome?
    reviewers.count == reviewers.hired.count
  end
end