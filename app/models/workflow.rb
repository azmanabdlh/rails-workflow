class Workflow < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers
  has_many :workflow_policies

  alias_method :policies, :workflow_policies


  def review_quorum_met?
    phase = policies.action_phase
    return false unless valid_phase?(phase)

    lead_quorum_met?(phase) or assoc_quorum_met?(phase)
  end

  def lead_quorum_met?(phase)
    policies.quorum.min_lead_reviewers == reviewers.lead.public_send(phase).size
  end


  def assoc_quorum_met?(phase)
    policies.quorum.min_reviewers == reviewers.assoc.public_send(phase).size
  end

  def reviewed?
    reviewers.pending.empty? and (reviewers.vote.size > 0 or review_quorum_met?)
  end

  def can_transition_to?(to)
    return false if stage.is_ended || to.has_children?

   (stage.direct_to?(to) or stage.enter_sub?(to) or stage.sibling?(to) or stage.leave_sub?(to)) and stage.same_post?(to)
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
