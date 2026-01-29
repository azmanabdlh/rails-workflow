class CandidateStage < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers

  def can_transition_to?(to)
    return false if stage.is_ended ||  reviewed?

    (stage.order + 1) == to.order && stage.same_post?(to)
  end

  def valid_transition_phase?(phase)
    return false if reviewed?

    Reviewer.phases.key?(phase.to_sym)
  end


  def reconcile(to)
    transaction do
      now = Time.current
      update!(exited_at: now)

      candidate.candidate_stages.find_or_create_by(
        stage_id: to.id
      ) do |c|
        c.entered_at = now
      end

      candidate.update!(current_stage_id: to.id)
    end
  end

  def decide_by!(user, phase, **options)
    raise "unknown phase #{phase}" if not valid_transition_phase?(phase)

    r = reviewers.filter do |r|
      r if r.reviewable_by?(user)
    end.first

    raise "invalid reviewer" if r.nil?

    r.mark(phase, **options)
  end

  def reviewed?
    n = reviewers.count
    n > 0 && (reviewers.hired.count == n) || (reviewers.cancelled.count == n)
  end

end