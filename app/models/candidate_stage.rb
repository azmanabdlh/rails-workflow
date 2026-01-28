class CandidateStage < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers


  def can_transition_stage?(stage_id)
    return false if outcome?

    stage.id == stage_id or (stage.order + 1 == Stage.find(stage_id).order)
  end

  def outcome?
    r = reviewers.find_by(order: 1)
    Reviewer::OUTCOME.index(r.phase.to_sym).present?
    # TODO:
  end

end
