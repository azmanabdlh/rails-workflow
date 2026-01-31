class Workflow < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers

  def can_transition_to?(to)
    # prevent transition if current stage ended or reviewed by adding "reviewed?"
    return false if stage.is_ended

    (stage.order + 1) == to.order && stage.same_post?(to)
  end

  def valid_transition_phase?(phase)
    Reviewer.phases.key?(phase.to_sym)
  end


  def reconcile(to)
    transaction do
      now = Time.current
      update!(exited_at: now)

      candidate.workflows.find_or_create_by(
        stage_id: to.id
      ) do |c|
        c.entered_at = now
      end

      candidate.update!(current_stage_id: to.id)
    end
  end

  def decide_by!(user, phase, **options)
    raise "unknown phase #{phase}" unless valid_transition_phase?(phase)

    r = reviewers.filter do |r|
      r if r.reviewable_by?(user)
    end.first

    raise "invalid reviewer" if r.nil?

    r.mark(phase, **options)
  end

  def reviewed?
    passed? || cancelled?
  end

  def passed?
    n = reviewers.count
    n > 0 && n == reviewers.passed.count
  end

  def cancelled?
    n = reviewers.count
    n > 0 && n == reviewers.cancelled.count
  end
end
