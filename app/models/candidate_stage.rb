class CandidateStage < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers


  def can_transition_stage?(stage_id)
    unless outcome?
      to = Stage.find_by(id: stage_id, post_id: stage.post_id)
      return (stage.order + 1) == to.order
    end

    false
  end

  def valid_transition_phase?(phase)
    unless outcome?
      idx = Reviewer::OUTCOME.index(phase)
      return unless idx.nil?
    end

    false
  end

  def outcome?
    reviewers.filter { |r| r if r.hired? }.present?
  end

end