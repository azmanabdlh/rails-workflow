class Workflow < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers
  has_many :workflow_policies

  alias_method :policies, :workflow_policies


  def review_quorum_met?(phase)
    return false unless valid_phase?(phase)

    lead_quorum_met?(phase) or assoc_quorum_met?(phase)
  end

  def lead_quorum_met?(phase)
    return true unless policy?(phase)

    reviewers.lead.public_send(phase).size >= policy(phase).quorum.min_lead_reviewers
  end

  def assoc_quorum_met?(phase)
    return true unless policy?(phase)

    reviewers.assoc.public_send(phase).size >= policy(phase).quorum.min_reviewers
  end

  def policy(phase)
    policies.public_send(phase).first
  end

  def policy?(phase)
    policies.public_send(phase).size > 0
  end

  def reviewed?(phase)
    reviewers.veto.public_send(phase).size > 0 or review_quorum_met?(phase)
  end

  def can_transition_to?(to)
    return false if stage.is_ended or to.has_children?

    return true if can_rollback?(to)

   (stage.direct_to?(to) or stage.enter_sub?(to) or stage.sibling?(to) or stage.leave_sub?(to)) and stage.same_post?(to)
  end

  def can_rollback?(to)
    cancelled? and to.order < stage.order and stage.same_post?(to)
  end

  def cancelled?
    action_phase = "cancelled"
    return false unless valid_phase?(action_phase)

    reviewers.veto.cancelled.size > 0 or lead_quorum_met?(action_phase) or assoc_quorum_met?(action_phase)
  end

  def passed?
    action_phase = "passed"
    return false unless valid_phase?(action_phase)

    reviewers.veto.passed.size > 0 or lead_quorum_met?(action_phase) or assoc_quorum_met?(action_phase)
  end

  def valid_phase?(phase)
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
    raise "unknown phase #{phase}" unless valid_phase?(phase)

    r = reviewers.filter do |r|
      r if r.reviewable_by?(user)
    end.first

    raise "invalid reviewer" if r.nil?

    r.mark(phase, **options)
  end
end
